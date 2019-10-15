//
//  SynchronizedUnSubscribeType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/15.
//  Copyright © 2019 jams. All rights reserved.
//

protocol SynchronizedUnsubscribeType : class {
    associatedtype DisposeKey
    
    func synchronizedUnsubscribe(_ disposeKey: DisposeKey)
}

