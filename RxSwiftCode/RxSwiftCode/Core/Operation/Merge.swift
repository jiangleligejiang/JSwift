//
//  Merge.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/17.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    func flatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source) -> Observable<Source.Element> {
        return FlatMap(source: self.asObservable(), selector: selector)
    }
    
}

private class MergeSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType> : Sink<Observer>, ObserverType where Observer.Element == SourceSequence.Element {
    
    typealias ResultType = Observer.Element
    typealias Element = SourceElement
    
    let _lock = RecursiveLock()
    
    var subscribeNext: Bool {
        return true
    }
    
    let _group = CompositeDisposable()
    let _sourceSubscription = SingleAssignmentDisposable()
    
    var _activeCount = 0
    var _stopped = false
    
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    @inline(__always)
    final private func nextElementArrived(element: SourceElement) -> SourceSequence? {
        self._lock.lock(); defer { self._lock.unlock() }
        if !self.subscribeNext {
            return nil
        }
        
        do {
            let value = try self.performMap(element)
            self._activeCount += 1
            return value
        } catch let e {
            self.forwardOn(.error(e))
            self.dispose()
            return nil
        }
    }
    
    func on(_ event: Event<SourceElement>) {
        switch event {
        case .next(let element):
            if let value = nextElementArrived(element: element) {
                self.subscribeInner(value.asObservable())
            }
        case .error(let error):
            self._lock.lock(); defer { self._lock.unlock() }
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self._lock.lock(); defer { self._lock.unlock() }
            self._stopped = false
            self._sourceSubscription.dispose()
            self.checkCompleted()
        }
    }
    
    func subscribeInner(_ source: Observable<Observer.Element>) {
        let iterDisposeKey = SingleAssignmentDisposable()
        if let disposeKey = self._group.insert(iterDisposeKey) {
            let iter = MergeSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposeKey.setDisposable(subscription)
        }
    }
    
    @inline(__always)
    func checkCompleted() {
        if self._stopped && self._activeCount == 0 {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
   
    func run(_ source: Observable<SourceElement>) -> Disposable {
        _ = self._group.insert(self._sourceSubscription)
        
        let subscription = source.subscribe(self)
        self._sourceSubscription.setDisposable(subscription)
        
        return self._group
    }
    
    func performMap(_ element: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }
    
}

fileprivate final class MergeSinkIter<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType> : ObserverType where SourceSequence.Element == Observer.Element {
    
    typealias Element = Observer.Element
    typealias Parent = MergeSink<SourceElement, SourceSequence, Observer>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    
    private let _parent: Parent
    private let _disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        self._parent = parent
        self._disposeKey = disposeKey
    }
    
    func on(_ event: Event<SourceSequence.Element>) {
        self._parent._lock.lock(); defer { self._parent._lock.unlock() }
        switch event {
        case .next(let value):
            self._parent.forwardOn(.next(value))
        case .error(let error):
            self._parent.forwardOn(.error(error))
            self._parent.dispose()
        case .completed:
            self._parent._group.remove(for: self._disposeKey)
            self._parent._activeCount -= 1
            self._parent.checkCompleted()
        }
    }
    
}

final private class FlatMapSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType> : MergeSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence
    
    let _selector:Selector
    
    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self._selector = selector
        super.init(observer: observer, cancel: cancel)
    }
    
    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        return try self._selector(element)
    }
}

final private class FlatMap<SourceElement, SourceSequence: ObservableConvertibleType> : Producer<SourceSequence.Element>{
    typealias Selector = (SourceElement) throws -> SourceSequence
    let _source: Observable<SourceElement>
    let _selector: Selector
    
    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self._source = source
        self._selector = selector
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = FlatMapSink(selector: self._selector, observer: observer, cancel: cancel)
        let subscription = sink.run(self._source)
        return (sink: sink, subscription: subscription)
    }
    
}
