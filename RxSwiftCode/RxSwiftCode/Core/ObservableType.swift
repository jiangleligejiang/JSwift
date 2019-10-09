//
//  ObservableType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public protocol ObservableType : ObservableConvertibleType {
    
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
    
}

extension ObservableType {
    
    /// Default implementation of converting `ObservableType` to `Observable`
    public func asObservable() -> Observable<Element> {
        return Observable.create { o in
            return self.subscribe(o)
        }
    }
}
