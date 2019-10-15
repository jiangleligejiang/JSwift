//
//  PublishSubject.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/15.
//  Copyright © 2019 jams. All rights reserved.
//

public final class PublishSubject<Element>
    : Observable<Element>
    , SubjectType
    , Cancelable
    , ObserverType
    , SynchronizedUnsubscribeType {
    
    public typealias SubjectObserverType = PublishSubject<Element>
    
    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType
    
    public var hasObservers: Bool {
        self._lock.lock()
        let count = self._observers.count > 0
        self._lock.unlock()
        return count
    }
    
    private let _lock = RecursiveLock()
    
    private var _isDisposed = false
    private var _observers = Observers()
    private var _stopped = false
    private var _stoppedEvent = nil as Event<Element>?
    
    public var isDisposed: Bool {
        return self._isDisposed
    }
    
    override init() {
        super.init()
    }
    
    public func on(_ event: Event<Element>) {
        dispatch(_synchronized_on(event), event)
    }
    
    func _synchronized_on(_ event: Event<Element>) -> Observers {
        self._lock.lock(); defer { self._lock.unlock() }
        switch event {
        case .next:
            if self.isDisposed || self._stopped {
                return Observers()
            }
            return self._observers
        case .completed, .error:
            if self._stoppedEvent == nil {
                self._stoppedEvent = event
                self._stopped = true
                let observers = self._observers
                self._observers.removeAll()
                return observers
            }
            return Observers()
        }
    }
    
    public override func subscribe<Observer>(_ observer: Observer) -> Disposable where Element == Observer.Element, Observer : ObserverType {
        self._lock.lock()
        let subscription = self._synchronized_subscribe(observer)
        self._lock.unlock()
        return subscription
    }
    
    func _synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if let stoppedEvent = self._stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }
        
        if self._isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }
        
        let key = self._observers.insert(observer.on)
        return SubscriptionDisposable(owner: self, key: key)
    }
    
    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        self._lock.lock()
        self._synchronized_unsubscribe(disposeKey)
        self._lock.unlock()
    }
    
    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = self._observers.removeKey(disposeKey)
    }
    
    public func asObserver() -> PublishSubject<Element> {
        return self
    }
    
    public func dispose() {
        self._lock.lock()
        self._synchronized_dispose()
        self._lock.unlock()
    }
    
    final func _synchronized_dispose() {
        self._isDisposed = true
        self._observers.removeAll()
        self._stoppedEvent = nil
    }
    
}
