//
//  LockOwner.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/18.
//  Copyright © 2019 jams. All rights reserved.
//

protocol LockOwnerType : class, Lock {
    var _lock: RecursiveLock { get }
}

extension LockOwnerType {
    func lock() {
        self._lock.lock()
    }
    
    func unlock() {
        self._lock.unlock()
    }
    
}
