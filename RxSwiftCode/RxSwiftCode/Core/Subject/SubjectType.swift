//
//  SubjectType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/15.
//  Copyright © 2019 jams. All rights reserved.
//

public protocol SubjectType: ObservableType {
    
    associatedtype Observer: ObserverType
    
    func asObserver() -> Observer
    
}
