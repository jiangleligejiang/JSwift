//
//  Platform.Darwin.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

import Darwin
import Foundation

extension Thread {
    
    static func setThreadLocalStorageValue<T: AnyObject> (_ value: T?, forKey key: NSCopying) {
        let currentThread = Thread.current
        let threadDictionay = currentThread.threadDictionary
        
        if let newValue = value {
            threadDictionay[key] = newValue
        } else {
            threadDictionay[key] = nil
        }
    }
    
    static func getThreadLocalStorageValueForKey<T>(_ key: NSCopying) -> T? {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary
        
        return threadDictionary[key] as? T
    }
    
}
