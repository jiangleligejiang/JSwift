//
//  Just.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/14.
//  Copyright © 2019 jams. All rights reserved.
//  Question: Just和JustScheduled使用两种不同方式复写，JustScheduled是因为要使用到相关schedule调用，所以要先调用Producer中的subscribe方法吗？

extension ObservableType {
    
    public static func just(_ element: Element) -> Observable<Element> {
        return Just(element: element)
    }
    
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return JustSchduled(element: element, scheduler: scheduler)
    }
    
}

final private class JustSchduledSink<Observer: ObserverType> : Sink<Observer> {
    
    typealias Parent = JustSchduled<Observer.Element>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let scheduler = self._parent._scheduler
        return scheduler.schedule(self._parent._element) { (element) -> Disposable in
            self.forwardOn(.next(element))
            return scheduler.schedule(()) { _ in
                self.forwardOn(.completed)
                self.dispose()
                return Disposables.create()
            }
        }
    }
    
}

final private class JustSchduled<Element> : Producer<Element> {
    
    fileprivate let _element: Element
    fileprivate let _scheduler: ImmediateSchedulerType
    
    init(element: Element, scheduler: ImmediateSchedulerType) {
        self._element = element
        self._scheduler = scheduler
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = JustSchduledSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
    
}


final private class Just<Element>: Producer<Element> {
    private let _element: Element
    
    init(element: Element) {
        self._element = element
    }
    
    override func subscribe<Observer>(_ observer: Observer) -> Disposable where Element == Observer.Element, Observer : ObserverType {
        observer.on(.next(self._element))
        observer.on(.completed)
        return Disposables.create()
    }
}
