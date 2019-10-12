//
//  AnyObserver.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public struct AnyObserver<Element> : ObserverType {
    
    public typealias EventHandler = (Event<Element>) -> Void
    
    private let observer: EventHandler
    
    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    public init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    public func on(_ event: Event<Element>) {
        return self.observer(event)
    }
    
    public func asObserver() -> AnyObserver<Element> {
        return self
    }
    
}
