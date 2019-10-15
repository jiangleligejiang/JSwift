//
//  DisposeBag.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/15.
//  Copyright © 2019 jams. All rights reserved.
//

extension Disposable {
    
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
    
}

public final class DisposeBag: DisposeBase {
    
    private var _lock = SpinLock()
    
    fileprivate var _disposables = [Disposable]()
    fileprivate var _isDisposed = false
    
    override init() {
        super.init()
    }
    
    public func insert(_ disposable: Disposable) {
        self._insert(disposable)?.dispose()
    }
    
    private func _insert(_ disposable: Disposable) -> Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            return disposable
        }
        self._disposables.append(disposable)
        return nil
    }
    
    private func dispose() {
        let oldDisposables = self._dispose()
        for disposable in oldDisposables {
            disposable.dispose()
        }
    }
    
    private func _dispose() -> [Disposable] {
        self._lock.lock(); defer { self._lock.unlock() }
        let disposables = self._disposables
        self._disposables.removeAll(keepingCapacity: false)
        self._isDisposed = true
        return disposables
    }
    
    deinit {
        self.dispose()
    }
    
}

extension DisposeBag {
    public convenience init(disposing disposables: Disposable...) {
        self.init()
        self._disposables += disposables
    }
    
    public convenience init(disposing disposables: [Disposable]) {
        self.init()
        self._disposables += disposables
    }
    
    public func insert(_ disposables: Disposable...) {
        self.insert(disposables)
    }
    
    public func insert(_ disposables: [Disposable]) {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            disposables.forEach { $0.dispose() }
        } else {
            self._disposables += disposables
        }
    }
}
