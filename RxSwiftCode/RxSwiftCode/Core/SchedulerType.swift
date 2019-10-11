//
//  SchedulerType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//

import Foundation

public typealias RxTimeInterval = DispatchTimeInterval

public typealias RxTime = Date

public protocol SchedulerType: ImmediateSchedulerType {
    
    var now: RxTime {
        get
    }
    
    func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable
    
    func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable
    
}

extension SchedulerType {
    
    func scheduleRecursive<State>(_ state: State, dueTime: RxTimeInterval, action: @escaping (State, AnyRecursiveScheduler<State>) -> Void) -> Disposable {
        let scheduler = AnyRecursiveScheduler(scheduler: self, action: action)
        scheduler.schedule(state, dueTime: dueTime)
        return Disposables.create(with: scheduler.dispose)
    }
    
}
