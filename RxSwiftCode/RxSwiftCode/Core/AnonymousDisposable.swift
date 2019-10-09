//
//  AnonymousDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

fileprivate final class AnonymousDisposable : DisposeBase, Cancelable {
    
    public typealias DisposeAction = () -> Void
    
    private let _isDisposed = AtomicInt(0)
    private var _disposeAction: DisposeAction?
    
    public var isDisposed: Bool {
        return isFlagSet(self._isDisposed, 1)
    }
    
    fileprivate init(_ disposeAction: @escaping DisposeAction) {
        self._disposeAction = disposeAction
        super.init()
    }
    
    fileprivate init(disposeAction: @escaping DisposeAction) {
        self._disposeAction = disposeAction
        super.init()
    }
    
    fileprivate func dispose() {
        if fetchOr(self._isDisposed, 1) == 0 {
            if let action = self._disposeAction {
                self._disposeAction = nil
                action()
            }
        }
    }
    
}

extension Disposables {
    
    public static func create(with dispose: @escaping () -> Void) -> Cancelable {
        return AnonymousDisposable(disposeAction: dispose)
    }
    
}
