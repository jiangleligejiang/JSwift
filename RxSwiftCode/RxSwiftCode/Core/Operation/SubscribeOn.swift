//
//  SubscribeOn.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/10.
//  Copyright © 2019 jams. All rights reserved.
//

extension ObservableType {
    
    public func subscribeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return SubscribeOn(source: self, scheduler: scheduler)
    }
    
}


final private class SubscribeOnSink<Ob: ObservableType, Observer: ObserverType>: Sink<Observer>, ObserverType where Ob.Element == Observer.Element {
    
    typealias Element = Observer.Element
    typealias Parent = SubscribeOn<Ob>

    let parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        self.forwardOn(event)
        
        if event.isStopEvent {
            self.dispose()
        }
    }
    
    func run() -> Disposable {
        let disposeEverything = SerialDisposable()
        let cancelSchedule = SingleAssignmentDisposable()
        
        disposeEverything.disposable = cancelSchedule
        
        let disposeSchedule = self.parent.scheduler.schedule(()) { _ -> Disposable in
            let subscription = self.parent.source.subscribe(self)
            disposeEverything.disposable = ScheduledDisposable(scheduler: self.parent.scheduler, disposable: subscription)
            return Disposables.create()
        }
        
        cancelSchedule.setDisposable(disposeSchedule)
        return disposeEverything
    }
    
}


final private class SubscribeOn<Ob: ObservableType>: Producer<Ob.Element> {
    let source: Ob
    let scheduler: ImmediateSchedulerType
    
    init(source: Ob, scheduler: ImmediateSchedulerType) {
        self.source = source
        self.scheduler = scheduler
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = SubscribeOnSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
