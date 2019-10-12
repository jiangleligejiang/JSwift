//
//  Create.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        return AnonymousObservable(subscribe)
    }
    
}

final private class AnonymousObservableSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    
    typealias Element = Observer.Element
    typealias Parent = AnonymousObservable<Element>
    
    private let _isStopped = AtomicInt(0)
    
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            if load(self._isStopped) == 1 {
                return
            }
            self.forwardOn(event)
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.forwardOn(event)
                self.dispose()
            }
        }
    }
    
    func run(_ parent: Parent) -> Disposable {
        return parent._subscribeHandler(AnyObserver(self))
    }
    
}


final private class AnonymousObservable<Element> : Producer<Element> {
    
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
    
    let _subscribeHandler: SubscribeHandler
    
    init(_ subscribeHandler: @escaping SubscribeHandler) {
        self._subscribeHandler = subscribeHandler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
    
}
