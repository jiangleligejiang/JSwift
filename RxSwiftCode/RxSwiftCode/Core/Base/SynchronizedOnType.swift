//
//  SynchronizedOnType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/18.
//  Copyright © 2019 jams. All rights reserved.
//

protocol SynchronizedOnType : class, ObserverType, Lock {
    func _synchronized_on(_ event: Event<Element>)
}

extension SynchronizedOnType {
    
    func synchronizedOn(_ event: Event<Element>) {
        self.lock(); defer { self.unlock() }
        self._synchronized_on(event)
    }
    
}
