//
//  Queue.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

struct Queue<T> : Sequence {
    
    typealias Generator = AnyIterator<T>
    
    private let _resizeFactor = 2
    
    private var _storage: ContiguousArray<T?>
    private var _count = 0
    private var _pushNextIndex = 0
    private let _initialCapacity: Int
    
    init(capacity: Int) {
        _initialCapacity = capacity
        _storage = ContiguousArray(repeating: nil, count: capacity)
    }
    
    private var dequeueIndex: Int {
        let index = _pushNextIndex - _count
        return index < 0 ? index + _storage.count : index
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    var count: Int {
        return _count
    }
    
    func peek() -> T {
        precondition(count > 0)
        return _storage[dequeueIndex]!
    }
    
    private mutating func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
        let count = _count
        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = _storage.count - dequeueIndex
        
        /// first batch is from dequeue index to end of array
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        /// second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0 ..< countElementsInFirstBatch] = _storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = _storage[0 ..< numberOfElementsInSecondBatch]
        
        _count = count
        _pushNextIndex = count
        _storage = newStorage
    }
    
    mutating func enqueue(_ element: T) {
        if count == _storage.count {
            resizeTo(Swift.max(_storage.count, 1) * _resizeFactor)
        }
        
        _storage[_pushNextIndex] = element
        _pushNextIndex += 1
        _count += 1
        
        if _pushNextIndex >= _storage.count {
            _pushNextIndex -= _storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)
        
        let index = dequeueIndex
        
        defer {
            _storage[dequeueIndex] = nil
            _count -= 1
        }
        
        return _storage[dequeueIndex]!
    }
    
    mutating func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        
        defer {
            let downSizeLimit = _storage.count / (_resizeFactor * _resizeFactor)
            if _count < downSizeLimit && downSizeLimit >= _initialCapacity {
                resizeTo(_storage.count / _resizeFactor)
            }
        }
        
        return dequeueElementOnly()
    }
 
    func makeIterator() -> AnyIterator<T> {
        var i = dequeueIndex
        var count = _count
        
        return AnyIterator {
            if count == 0 {
                return nil
            }
            
            defer {
                count -= 1
                i += 1
            }
            
            if i >= self._storage.count {
                i -= self._storage.count
            }
            
            return self._storage[i]
        }
    }
    
}
