//
//  Bag.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/11.
//  Copyright © 2019 jams. All rights reserved.
//


let arrayDictionayMaxSize = 30

struct BagKey {
    fileprivate let rawValue: UInt64
}

struct Bag<T> : CustomDebugStringConvertible {
    
    typealias KeyType = BagKey
    
    typealias Entry = (key: BagKey, value: T)
    
    fileprivate var _nextKey: BagKey = BagKey(rawValue: 0)
    
    var _key0: BagKey?
    var _value0: T?
    
    var _pairs = ContiguousArray<Entry>()
    
    var _dictionary:[BagKey : T]?
    
    var _onlyFastPath = true
    
    init() {
        
    }
    
    mutating func insert(_ element: T) -> BagKey {
        let key = _nextKey
        _nextKey = BagKey(rawValue: _nextKey.rawValue &+ 1)
        
        if _key0 == nil {
            _key0 = key
            _value0 = element
            return key
        }
        
        _onlyFastPath = false
        
        if _dictionary != nil {
            _dictionary![key] = element
            return key
        }
        
        if _pairs.count < arrayDictionayMaxSize {
            _pairs.append((key: key, value: element))
            return key
        }
        
        _dictionary = [key: element]
        
        return key
    }
    
    var count: Int {
        let dictionaryCount: Int = _dictionary?.count ?? 0
        return (_value0 != nil ? 1 : 0) + _pairs.count + dictionaryCount
    }
    
    mutating func removeAll() {
        _key0 = nil
        _value0 = nil
        
        _pairs.removeAll(keepingCapacity: false)
        _dictionary?.removeAll(keepingCapacity: false)
    }
    
    mutating func removeKey(_ key: BagKey) -> T? {
        if _key0 == key {
            _key0 = nil
            let value = _value0!
            _value0 = nil
            return value
        }
        
        if let existingObject = _dictionary?.removeValue(forKey: key) {
            return existingObject
        }
        
        for i in 0 ..< _pairs.count where _pairs[i].key == key {
            let value = _pairs[i].value
            _pairs.remove(at: i)
            return value
        }
        
        return nil
    }
    
}

extension Bag {
    
    var debugDescription: String {
        return "\(self.count) elements in Bag"
    }
}

extension Bag {
    func forEach(_ action: (T) -> Void) {
        if _onlyFastPath {
            if let value0 = _value0 {
                action(value0)
            }
            return
        }
        
        let value0 = _value0
        let dictionary = _dictionary
        
        if let value0 = value0 {
            action(value0)
        }
        
        for i in 0 ..< _pairs.count {
            action(_pairs[i].value)
        }
        
        if dictionary?.count ?? 0 > 0 {
            for element in dictionary!.values {
                action(element)
            }
        }
        
    }
}


extension BagKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

func ==(lhs: BagKey, rhs: BagKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
