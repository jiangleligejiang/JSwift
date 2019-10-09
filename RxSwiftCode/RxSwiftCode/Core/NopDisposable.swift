//
//  NopDisposable.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

fileprivate struct NopDisposable : Disposable {
    
    fileprivate static let noOp: Disposable = NopDisposable()
    
    fileprivate init() {
        
    }
    
    func dispose() {
        
    }
    
}

extension Disposables {
    
    static public func create() -> Disposable {
        return NopDisposable.noOp
    }
    
}
