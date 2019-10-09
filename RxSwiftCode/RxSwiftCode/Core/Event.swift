//
//  Event.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

public enum Event<Element> {
    
    case next(Element)
    
    case error(Swift.Error)
    
    case completed
    
}
