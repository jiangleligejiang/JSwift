//
//  ViewController.swift
//  RxSwiftCode
//
//  Created by jams on 2019/10/8.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onCompleted()
            return Disposables.create()
        }.subscribe(onNext: { (num) in
            print("receive num \(num)")
        }, onError: { (error) in
            print("error: \(error.localizedDescription)")
        }, onCompleted: {
            print("receive complete")
        }) 
    }


}

