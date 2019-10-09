//
//  Sink.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/9.
//  Copyright © 2019 jams. All rights reserved.
//

class Sink<Observer: ObserverType>: Disposable {
    
    fileprivate let _observer: Observer
    fileprivate let _cancel: Cancelable
    fileprivate let _diposed = AtomicInt(0)
    
    init(observer: Observer, cancel: Cancelable) {
        self._observer = observer
        self._cancel = cancel
    }
    
    final func forwardOn(_ event: Event<Observer.Element>) {
        if isFlagSet(self._diposed, 1) {
            return
        }
        self._observer.on(event)
    }
    
    final func forwarder() -> SinkForward<Observer> {
        return SinkForward(forward: self)
    }
    
    final var disposed: Bool {
        return isFlagSet(self._diposed, 1)
    }
    
    func dispose() {
        fetchOr(self._diposed, 1)
        self._cancel.dispose()
    }
}

final class SinkForward<Observer: ObserverType>: ObserverType {
    
    typealias Element = Observer.Element
    
    private let _forward: Sink<Observer>

    init(forward: Sink<Observer>) {
        self._forward = forward
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self._forward._observer.on(event)
        case .error, .completed:
            self._forward._observer.on(event)
            self._forward._cancel.dispose()
        }
    }
}
