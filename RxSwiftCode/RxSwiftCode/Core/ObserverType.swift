//
//  ObserverType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public protocol ObserverType {
    associatedtype Element
    
    func on(_ event: Event<Element>)
}


extension ObserverType {
    
    public func onNext(_ element: Element) {
        self.on(.next(element))
    }
    
    public func onCompleted() {
        self.on(.completed)
    }
    
    public func onError(_ error: Swift.Error) {
        self.on(.error(error))
    }
    
}
