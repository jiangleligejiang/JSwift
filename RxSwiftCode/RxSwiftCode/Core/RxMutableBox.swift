//
//  RxMutableBox.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

final class RxMutableBox<T> : CustomDebugStringConvertible {
    
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

extension RxMutableBox {
    
    var debugDescription: String {
        return "MutatingBox(\(self.value))"
    }
    
}
