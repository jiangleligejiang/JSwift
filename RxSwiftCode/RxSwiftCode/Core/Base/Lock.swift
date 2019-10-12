//
//  Lock.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//
import Foundation

protocol Lock {
    func lock()
    func unlock()
}

typealias RecursiveLock = NSRecursiveLock

typealias SpinLock = RecursiveLock

extension RecursiveLock : Lock {
    
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        self.lock()
        defer {
            self.unlock()
        }
        action()
    }
    
    @inline(__always)
    final func calculateLocked<T>(_ action: () -> T) -> T {
        self.lock()
        defer {
            self.unlock()
        }
        return action()
    }
    
    @inline(__always)
    final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        self.lock()
        defer {
            self.unlock()
        }
        let result = try action()
        return result
    }
    
}


