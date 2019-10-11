//
//  SerialDispatchQueueScheduler.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//
import Foundation

public class SerialDispatchQueueScheduler : SchedulerType {
    
    public typealias Time = Date
    
    public var now: Date {
        return Date()
    }
    
    let configuration: DispatchQueueConfiguration
    
    init(serialQueue: DispatchQueue, leeway: DispatchTimeInterval =  DispatchTimeInterval.nanoseconds(0)) {
        self.configuration = DispatchQueueConfiguration(queue: serialQueue, leeway: leeway)
    }
    
    public convenience init(internalSerialQueueName: String, serialQueueConfiguration: ((DispatchQueue) -> Void)? = nil, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        let queue = DispatchQueue(label: internalSerialQueueName, attributes: [])
        serialQueueConfiguration?(queue)
        self.init(serialQueue: queue, leeway: leeway)
    }
    
    public convenience init(queue: DispatchQueue, internalSerialQueueName: String, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        let serialQueue = DispatchQueue(label: internalSerialQueueName, attributes: [], target: queue)
        self.init(serialQueue: serialQueue, leeway: leeway)
    }
    
    @available(iOS 8, OSX 10.10, *)
    public convenience init(qos: DispatchQoS, internalSerialQueueName: String = "rx.global_dispatch_queue.serial", leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.init(serialQueue: DispatchQueue.global(qos: qos.qosClass), leeway: leeway)
    }
    
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        self.scheduleInternal(state, action: action)
    }
    
    func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.configuration.schedule(state, action: action)
    }
    
    public final func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.configuration.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    public final func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        return self.configuration.schedulePeriodic(state, startAfter: startAfter, period: period, action: action)
    }
    
}
