//
//  CurrentThreadScheduler.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//
import Foundation

private class CurrentThreadSchedulerQueueKey: NSObject, NSCopying {
    
    static let instance = CurrentThreadSchedulerQueueKey()
    private override init() {
        super.init()
    }
    
    override var hash: Int {
        return 0
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
}

public class CurrentThreadScheduler: ImmediateScheduleType {
    
    typealias ScheduleQueue = RxMutableBox<Queue<ScheduledItemType>>
    
    public static let instance = CurrentThreadScheduler()
    
    private static var isScheduleRequiredKey: pthread_key_t = { () -> pthread_key_t in
        let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
        defer { key.deallocate() }
        guard pthread_key_create(key, nil) == 0 else {
            rxFatalError("isScheduleRequired key creation failed")
        }
        return key.pointee
    }()
    
    private static var scheduleInProgressSentinel: UnsafeRawPointer = { () -> UnsafeRawPointer in
        return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
    }()
    
    static var queue: ScheduleQueue? {
        get {
            return Thread.getThreadLocalStorageValueForKey(CurrentThreadSchedulerQueueKey.instance)
        }
        set {
            Thread.setThreadLocalStorageValue(newValue, forKey: CurrentThreadSchedulerQueueKey.instance)
        }
    }
    
    public static fileprivate(set) var isScheduleRequired: Bool {
        get {
            return pthread_getspecific(CurrentThreadScheduler.isScheduleRequiredKey) == nil
        }
        set (isScheduleRequried) {
            if pthread_setspecific(CurrentThreadScheduler.isScheduleRequiredKey, isScheduleRequried ? nil : scheduleInProgressSentinel) != 0 {
                rxFatalError("pthread_setspecific failed")
            }
        }
    }
    
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        if CurrentThreadScheduler.isScheduleRequired {
            CurrentThreadScheduler.isScheduleRequired = false
            
            let disposable = action(state)
            
            defer {
                CurrentThreadScheduler.isScheduleRequired = true
                CurrentThreadScheduler.queue = nil
            }
            
            guard let queue = CurrentThreadScheduler.queue else {
                return disposable
            }
            
            while let latest = queue.value.dequeue() {
                if latest.isDisposed {
                    continue
                }
                latest.invoke()
            }
            
            return disposable
        }
        
        let existingQueue = CurrentThreadScheduler.queue
        let queue: RxMutableBox<Queue<ScheduledItemType>>
        if let existingQueue = existingQueue {
            queue = existingQueue
        } else {
            queue = RxMutableBox(Queue<ScheduledItemType>(capacity: 1))
            CurrentThreadScheduler.queue = queue
        }
        
        let scheduledItem = ScheduledItem(action: action, state: state)
        queue.value.enqueue(scheduledItem)
        
        return scheduledItem
    }
    
}
