//
//  BinaryDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

private final class BinaryDisposable: DisposeBase, Cancelable {
    
    private let _isDisposed = AtomicInt(0)
    
    private var _disposable1: Disposable?
    private var _disposable2: Disposable?
    
    var isDisposed: Bool {
        return isFlagSet(self._isDisposed, 1)
    }
    
    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self._disposable1 = disposable1
        self._disposable2 = disposable2
        super.init()
    }
    
    func dispose() {
        if fetchOr(self._isDisposed, 1) == 0 {
            self._disposable1?.dispose()
            self._disposable2?.dispose()
            self._disposable1 = nil
            self._disposable2 = nil
        }
    }
    
}


extension Disposables {
    
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        return BinaryDisposable(disposable1, disposable2)
    }
    
}
