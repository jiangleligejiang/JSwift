//
//  AnonymousObserver.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

final class AnonymousObserver<Element>: ObserverBase<Element> {
    
    typealias EventHandler = (Event<Element>) -> Void
    
    private let _eventHandler: EventHandler
    
    init(_ eventHandler: @escaping EventHandler) {
        self._eventHandler = eventHandler
    }
    
    override func onCore(_ event: Event<Element>) {
        return self._eventHandler(event)
    }
    
}
