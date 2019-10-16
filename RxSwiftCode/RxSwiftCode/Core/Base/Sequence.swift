//
//  Sequence.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/16.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    public static func of(_ elements: Element ..., scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> {
        return ObservableSequence(elements: elements, scheduler: scheduler)
    }
    
}

final private class ObservableSequenceSink<Sequence: Swift.Sequence, Observer: ObserverType> : Sink<Observer> where Sequence.Element == Observer.Element {
    
    typealias Parent = ObservableSequence<Sequence>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        
        return self._parent._scheduler.scheduleRecursive(self._parent._elements.makeIterator()) { iterator, recurse in
            var mutableIterator = iterator
            if let next = mutableIterator.next() {
                self.forwardOn(.next(next))
                recurse(mutableIterator)
            } else {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
    
}

final private class ObservableSequence<Sequence: Swift.Sequence>: Producer<Sequence.Element> {
    fileprivate let _elements: Sequence
    fileprivate let _scheduler: ImmediateSchedulerType
    
    init(elements: Sequence, scheduler: ImmediateSchedulerType) {
        self._elements = elements
        self._scheduler = scheduler
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = ObservableSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
    
}
