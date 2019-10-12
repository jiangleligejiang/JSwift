//
//  CompositeDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/11.
//  Copyright © 2019 jams. All rights reserved.
//

public final class CompositeDisposable : DisposeBase, Cancelable {
    
    public struct DisposeKey {
        fileprivate let key: BagKey
        fileprivate init(key: BagKey) {
            self.key = key
        }
    }
    
    private var _lock = SpinLock()
    
    private var _disposables: Bag<Disposable>? = Bag()
    
    public var isDisposed: Bool {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables == nil
    }

    public override init() {
        
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable) {
        _ = self._disposables?.insert(disposable1)
        _ = self._disposables?.insert(disposable2)
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        _ = self._disposables?.insert(disposable1)
        _ = self._disposables?.insert(disposable2)
        _ = self._disposables?.insert(disposable3)
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposable4: Disposable, _ disposables: Disposable ...) {
        _ = self._disposables?.insert(disposable1)
        _ = self._disposables?.insert(disposable2)
        _ = self._disposables?.insert(disposable3)
        _ = self._disposables?.insert(disposable4)
        
        for disposable in disposables {
            _ = self._disposables?.insert(disposable)
        }
    }
    
    public init(disposables: [Disposable]) {
        for disposable in disposables {
            _ = self._disposables?.insert(disposable)
        }
    }

    public func insert(_ disposable: Disposable) -> DisposeKey? {
        let key = self._insert(disposable)
        if key == nil {
            disposable.dispose()
        }
        return key
    }
    
    private func _insert(_ disposable: Disposable) -> DisposeKey? {
        self._lock.lock(); defer { self._lock.unlock() }
        let bagKey = self._disposables?.insert(disposable)
        return bagKey.map(DisposeKey.init)
    }
    
    public var count: Int {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables?.count ?? 0
    }
    
    public func remove(for disposeKey: DisposeKey) {
        self._remove(for: disposeKey)?.dispose()
    }
    
    private func _remove(for disposeKey: DisposeKey) -> Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables?.removeKey(disposeKey.key)
    }
    
    public func dispose() {
        if let disposables = self._dispose() {
            disposeAll(in: disposables)
        }
    }
    
    private func _dispose() -> Bag<Disposable>? {
        self._lock.lock(); defer { self._lock.unlock() }
        
        let disposeBag = self._disposables
        self._disposables = nil
        return disposeBag
    }
    
}

extension CompositeDisposable {
    
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) -> Cancelable {
        return CompositeDisposable(disposable1, disposable2, disposable3)
    }
    
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposable4: Disposable, _ disposables: Disposable ...) -> Cancelable {
        var disposables = disposables
        disposables.append(disposable1)
        disposables.append(disposable2)
        disposables.append(disposable3)
        return CompositeDisposable(disposables: disposables)
    }
    
    public static func create(_ disposables: [Disposable]) -> Cancelable {
        switch disposables.count {
        case 2:
            return Disposables.create(disposables[0], disposables[1])
        default:
            return CompositeDisposable(disposables: disposables)
        }
    }
    
}
