//
//  Single.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/14.
//  Copyright © 2019 jams. All rights reserved.
//

public enum SingleTrait { }

public typealias Single<Element> = PrimitiveSequence<SingleTrait, Element>

public enum SingleEvent<Element> {
    case success(Element)
    case error(Swift.Error)
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    
    public typealias SingleObserver = (SingleEvent<Element>) -> Void
    
    public static func create(subscribe: @escaping (@escaping SingleObserver) -> Disposable) -> Single<Element> {
        let source = Observable<Element>.create { (observer) -> Disposable in
            return subscribe { event in
                switch event {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .error(let error):
                    observer.on(.error(error))
                }
            }
        }
        return PrimitiveSequence(raw: source)
    }
    
    public func subscribe(_ observer: @escaping (SingleEvent<Element>) -> Void) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true
            
            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                rxFatalError("Singles can't emit a completion event")
            }
        }
    }
    
    public func subscribe(onSuccess: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil) -> Disposable {
        return self.primitiveSequence.subscribe { event in
            switch event {
            case .success(let element):
                onSuccess?(element)
            case .error(let error):
                onError?(error)
            }
        }
    }
    
}


