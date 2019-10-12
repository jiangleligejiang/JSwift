//
//  DispatchQueue+Extensions.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/11.
//  Copyright © 2019 jams. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    private static var token: DispatchSpecificKey<()> = {
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()
    
    static var isMain: Bool {
        return DispatchQueue.getSpecific(key: token) != nil
    }
    
}
