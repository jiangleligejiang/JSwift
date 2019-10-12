//
//  ScheduledItemType.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

protocol ScheduledItemType: Cancelable, InvocableType {
    
    func invoke()
    
}
