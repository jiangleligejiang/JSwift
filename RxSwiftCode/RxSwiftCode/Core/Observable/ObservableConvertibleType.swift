//
//  ObservableConvertibleType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public protocol ObservableConvertibleType {
    
    associatedtype Element
    
    func asObservable() -> Observable<Element>
}
