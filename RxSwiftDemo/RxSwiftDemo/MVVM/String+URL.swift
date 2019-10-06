//
//  String+URL.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/10/6.
//  Copyright © 2019 jams. All rights reserved.
//

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
