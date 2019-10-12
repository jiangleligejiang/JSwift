//
//  ScheduledDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//

private let disposeScheduledDisposable: (ScheduledDisposable) -> Disposable = { sd in
    sd.disposeInner()
    return Disposables.create()
}

public final class ScheduledDisposable : Cancelable {
    
    public let scheduler: ImmediateSchedulerType
    
    private let _isDisposed = AtomicInt(0)
    
    private var _disposable: Disposable?
    
    public var isDisposed: Bool {
        return isFlagSet(self._isDisposed, 1)
    }
    
    public init(scheduler: ImmediateSchedulerType, disposable: Disposable) {
        self.scheduler = scheduler
        self._disposable = disposable
    }
    
    public func dispose() {
        _ = self.scheduler.schedule(self, action: disposeScheduledDisposable)
    }
    
    func disposeInner() {
        if fetchOr(self._isDisposed, 1) == 0 {
            self._disposable!.dispose()
            self._disposable = nil
        }
        
    }
}
