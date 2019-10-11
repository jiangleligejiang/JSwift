//
//  ImmediateScheduledType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public protocol ImmediateSchedulerType {
    
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
    
}

extension ImmediateSchedulerType {
    
    public func scheduleRecursive<State>(_ state: State, action: @escaping (_ state: State, _ recurse: (State) -> Void) -> Void) -> Disposable {
        let recursiveScheduler = RecursiveImmediateScheduler(action: action, scheduler: self)
        recursiveScheduler.schedule(state)
        return Disposables.create(with: recursiveScheduler.dispose)
    }
    
}
