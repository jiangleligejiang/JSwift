//
//  Zip+Arity.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/18.
//  Copyright © 2019 jams. All rights reserved.
//


extension ObservableType {
    
    public static func zip<O1: ObservableType, O2: ObservableType>(_ source1: O1, _ source2: O2, resultSelector: @escaping (O1.Element, O2.Element) -> Element) -> Observable<Element> {
        return Zip2(source1: source1.asObservable(), source2: source2.asObservable(), resultSelector: resultSelector)
    }
    
}

final class ZipSink2_<E1, E2, Observer: ObserverType> : ZipSink<Observer> {
    typealias Result = Observer.Element
    
    typealias Parent = Zip2<E1, E2, Result>
    
    let _parent: Parent
    
    var _value1: Queue<E1> = Queue(capacity: 2)
    var _value2: Queue<E2> = Queue(capacity: 2)
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(arity: 2, observer: observer, cancel: cancel)
    }
    
    override func hasElements(_ index: Int) -> Bool {
        switch index {
        case 0:
            return !self._value1.isEmpty
        case 1:
            return !self._value2.isEmpty
        default:
            rxFatalError("Unhandled case (Function)")
        }
    }
    
    func run() -> Disposable {
        let subscription1 = SingleAssignmentDisposable()
        let subscription2 = SingleAssignmentDisposable()
        
        let observer1 = ZipObserver(lock: self._lock, parent: self, index: 0, setNextValue: { self._value1.enqueue($0) }, this: subscription1)
        let observer2 = ZipObserver(lock: self._lock, parent: self, index: 1, setNextValue: { self._value2.enqueue($0) }, this: subscription2)
        
        subscription1.setDisposable(self._parent.source1.subscribe(observer1))
        subscription2.setDisposable(self._parent.source2.subscribe(observer2))
        
        return Disposables.create(subscription1, subscription2)
    }
    
    override func getResult() throws -> Result {
        return try self._parent._resultSelector(self._value1.dequeue()!, self._value2.dequeue()!)
    }
    
}

final class Zip2<E1, E2, Result> : Producer<Result> {
    typealias ResultSelector = (E1, E2) throws -> Result
    
    let source1: Observable<E1>
    let source2: Observable<E2>
    
    let _resultSelector: ResultSelector
    
    init(source1: Observable<E1>, source2: Observable<E2>, resultSelector: @escaping ResultSelector) {
        self.source1 = source1
        self.source2 = source2
        self._resultSelector = resultSelector
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = ZipSink2_(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
