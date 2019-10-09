//
//  SingleAssignmentDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

public final class SingleAssignmentDisposable : Disposable, Cancelable {
    
    fileprivate enum DisposeState: Int32 {
        case disposed = 1
        case diposableSet = 2
    }
    
    private let _state = AtomicInt(0)
    private var _disposable = nil as Disposable?
    
    public var isDisposed: Bool {
        return isFlagSet(self._state, DisposeState.disposed.rawValue)
    }
    
    public func setDisposable(_ disposable: Disposable) {
        self._disposable = disposable
        
        let previousState = fetchOr(self._state, DisposeState.diposableSet.rawValue)
        
        if (previousState & DisposeState.diposableSet.rawValue) != 0 {
            rxFatalError("oldState.disposable != nil")
        }
        
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            disposable.dispose()
            self._disposable = nil
        }
    }
    
    public func dispose() {
        let previousState = fetchOr(self._state, DisposeState.disposed.rawValue)
        
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }
        
        if (previousState & DisposeState.diposableSet.rawValue) != 0 {
            guard let disposable = self._disposable else {
                rxFatalError("Disposable not set")
            }
            disposable.dispose()
            self._disposable = nil
        }
    }
    
}
