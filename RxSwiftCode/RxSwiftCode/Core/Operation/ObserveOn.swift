//
//  ObserveOn.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    public func observeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        
        if let scheduler = scheduler as? SerialDispatchQueueScheduler {
            return ObserveOnSerialDispatchQueue(source: self.asObservable(), scheduler: scheduler)
        } else {
            return ObserveOn(source: self.asObservable(), scheduler: scheduler)
        }
        
    }
    
}

final private class ObserveOn<Element>: Producer<Element> {
    
    let scheduler: ImmediateSchedulerType
    let source: Observable<Element>
    
    init(source: Observable<Element>, scheduler: ImmediateSchedulerType) {
        self.scheduler = scheduler
        self.source = source
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = ObserveOnSink(scheduler: self.scheduler, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
}

enum ObserveOnState: Int32 {
    case stopped = 0
    case running = 1
}

final private class ObserveOnSink<Observer: ObserverType>: ObserverBase<Observer.Element> {
    typealias Element = Observer.Element
    
    let _scheduler: ImmediateSchedulerType
    
    var _lock = SpinLock()
    let _observer: Observer
    
    var _state = ObserveOnState.stopped
    var _queue = Queue<Event<Element>>(capacity: 10)
    
    let _scheduleDisposable = SerialDisposable()
    let _cancel: Cancelable
    
    init(scheduler: ImmediateSchedulerType, observer: Observer, cancel: Cancelable) {
        self._scheduler = scheduler
        self._observer = observer
        self._cancel = cancel
    }
    
    override func onCore(_ event: Event<Observer.Element>) {
        let shouldStart = self._lock.calculateLocked { () -> Bool in
            self._queue.enqueue(event)
            
            switch self._state {
            case .stopped:
                self._state = .running
                return true
            case .running:
                return false
            }
        }
        if shouldStart {
            self._scheduleDisposable.disposable = self._scheduler.scheduleRecursive((), action: self.run)
        }
    }
    
    
    func run(_ state: (), _ recurse: (()) -> Void) {
         let (nextEvent, observer) = self._lock.calculateLocked{ () -> (Event<Element>?, Observer) in
            if !self._queue.isEmpty {
                return (self._queue.dequeue(), self._observer)
            }
            else {
                self._state = .stopped
                return (nil, self._observer)
            }
        }
        
        if let nextEvent = nextEvent, !self._cancel.isDisposed {
            observer.on(nextEvent)
            if nextEvent.isStopEvent {
                self.dispose()
            }
        } else {
            return
        }
        
        let shouldContinue = self._shouldContinue_synchronized()
        
        if shouldContinue {
            recurse(())
        }
    }
    
    
    func _shouldContinue_synchronized() -> Bool {
        self._lock.lock(); defer { self._lock.unlock() }
        
        if !self._queue.isEmpty {
            return true
        } else {
            self._state = .stopped
            return false
        }
    }
    
    override func dispose() {
        super.dispose()
        self._cancel.dispose()
        self._scheduleDisposable.dispose()
    }
}


final private class ObserveOnSerialDispatchQueueSink<Observer: ObserverType>: ObserverBase<Observer.Element> {
    let scheduler: SerialDispatchQueueScheduler
    let observer: Observer
    
    let cancel: Cancelable
    
    var cachedScheduleLamda: (((sink: ObserveOnSerialDispatchQueueSink<Observer>, event: Event<Element>)) -> Disposable)!
    
    init(scheduler: SerialDispatchQueueScheduler, observer: Observer, cancel: Cancelable) {
        self.scheduler = scheduler
        self.observer = observer
        self.cancel = cancel
        
        super.init()
        
        self.cachedScheduleLamda = { pair in
            guard !cancel.isDisposed else { return Disposables.create() }
            
            pair.sink.observer.on(pair.event)
            
            if pair.event.isStopEvent {
                pair.sink.dispose()
            }
            
            return Disposables.create()
        }
    }
    
    override func onCore(_ event: Event<Observer.Element>) {
        _ = self.scheduler.schedule((self, event), action: self.cachedScheduleLamda)
    }
    
    override func dispose() {
        super.dispose()
        self.cancel.dispose()
    }
    
}

final private class ObserveOnSerialDispatchQueue<Element>: Producer<Element> {
    
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<Element>
    
    init(source: Observable<Element>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = ObserveOnSerialDispatchQueueSink(scheduler: self.scheduler, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
}
