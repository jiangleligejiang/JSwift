//
//  MainScheduler.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/11.
//  Copyright © 2019 jams. All rights reserved.
//

import Foundation

public final class MainScheduler: SerialDispatchQueueScheduler {
    
    private let _mainQueue: DispatchQueue
    
    let numberEnqueued = AtomicInt(0)
    
    public init() {
        self._mainQueue = DispatchQueue.main
        super.init(serialQueue: self._mainQueue)
    }
    
    public static let instance = MainScheduler()
    
    public static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)
    
    public class func ensureExecutingOnScheduler(errorMessage: String? = nil) {
        if !DispatchQueue.isMain {
            rxFatalError(errorMessage ?? "Executing on background thread.Please use `MainScheduler.instance.schedule` to schedule work on main thread.")
        }
    }
    
    public class func ensureRunningOnMainThread(errorMessage: String? = nil) {
        guard Thread.isMainThread else {
            rxFatalError(errorMessage ?? "Running on background thread.")
        }
    }
    
    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let previousNumberEqueued = increment(self.numberEnqueued)
        
        if DispatchQueue.isMain && previousNumberEqueued == 0 {
            let disposable = action(state)
            decrement(self.numberEnqueued)
            return disposable
        }
        
        let cancel = SingleAssignmentDisposable()
        
        self._mainQueue.async {
            if !cancel.isDisposed {
                _ = action(state)
            }
            
            decrement(self.numberEnqueued)
        }
        
        return cancel
    }
    
    
    
}
