//
//  PrimitiveSequence.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/14.
//  Copyright © 2019 jams. All rights reserved.
//

public struct PrimitiveSequence<Trait, Element> {
    
    let source: Observable<Element>
    
    init(raw: Observable<Element>) {
        self.source = raw
    }

}

public protocol PrimitiveSequenceType {
    
    associatedtype Trait
    
    associatedtype Element
    
    var primitiveSequence: PrimitiveSequence<Trait, Element> { get }
    
}

extension PrimitiveSequence: PrimitiveSequenceType {
    
    public var primitiveSequence: PrimitiveSequence<Trait, Element> {
        return self
    }
    
}

extension PrimitiveSequence: ObservableConvertibleType {
    
    public func asObservable() -> Observable<Element> {
        return self.source
    }
    
}
