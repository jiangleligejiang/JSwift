//
//  Bag+Rx.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/11.
//  Copyright © 2019 jams. All rights reserved.
//


func disposeAll(in bag: Bag<Disposable>) {
    
    bag._value0?.dispose()
    
    if bag._onlyFastPath {
        return
    }
    
    let pairs = bag._pairs
    for i in 0 ..< pairs.count {
        pairs[i].value.dispose()
    }
    
    if let dictionary = bag._dictionary {
        for element in dictionary.values {
            element.dispose()
        }
    }
    
}
