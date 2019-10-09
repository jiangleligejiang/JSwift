//
//  ObservableType+Extensions.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    public func subscribe(_ on: @escaping (Event<Element>) -> Void) -> Disposable {
        let observer = AnonymousObserver { e in
            on(e)
        }
        return self.asObservable().subscribe(observer)
    }
    
    public func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted:(() -> Void)? = nil, onDisposed:(() -> Void)? = nil) -> Disposable {
        let disposable: Disposable
        
        if let disposed = onDisposed {
            disposable = Disposables.create(with: disposed)
        } else {
            disposable = Disposables.create()
        }
        
        let observer = AnonymousObserver<Element> { event in
            switch event {
            case .next(let value):
                onNext?(value)
            case .error(let error):
                if let onError = onError {
                    onError(error)
                }
            
                disposable.dispose()
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }
        return Disposables.create(self.asObservable().subscribe(observer), disposable)
    }
}
