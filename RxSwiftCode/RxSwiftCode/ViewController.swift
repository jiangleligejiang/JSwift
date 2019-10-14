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
        
        //self.simpleTest()
        self.singleOpTest()
    }

    func simpleTest() {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onCompleted()
            return Disposables.create()
        }
        
        let _ = observable.subscribe(onNext: { (num) in
            print("receive num \(num)")
        }, onError: { (error) in
            print("error:\(error.localizedDescription)")
        }, onCompleted: {
            print("recieve complete")
        }) {
            print("finished")
        }
    }
    
    func justOpTest() {
        let _ = Observable.just([1,2,3], scheduler: SerialDispatchQueueScheduler.init(qos: .userInitiated))
            .subscribe(onNext: { (num) in
                print("receive num is in main thread: \(Thread.current.isMainThread)")
                print("receive num \(num)")
            }, onError: { (error) in
                print("error:\(error.localizedDescription)")
            }, onCompleted: {
                print("recieve complete is in main thread: \(Thread.current.isMainThread)")
            }) {
                print("finished")
        }
    }
    
    func singleOpTest() {
           
           func getRepo(_ repo: String) -> Single<[String: Any]> {
               
               return Single<[String: Any]>.create { (single) -> Disposable in
                   let url = URL(string: "https://api.github.com/repos/\(repo)")!
                   let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                       
                       if let error = error {
                           single(.error(error))
                           return
                       }
                       
                       guard let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                           let result = json as? [String: Any] else {
                               single(.error(NSError.init(domain: "DataError.cantParseJSON", code: 2, userInfo: nil)))
                               return
                           }
                       
                       single(.success(result))
                       
                   }
                   task.resume()
                   return Disposables.create {
                       task.cancel()
                   }
               }
           }
           
           let _ = getRepo("ReactiveX/RxSwift")
            .subscribe(onSuccess: { (result) in
                print("result: \(result)")
            }) { (error) in
                print("error: \(error)")
            }
        
    }
    
    func schedulersTest() {
        
        let rxData: Observable<String> = Observable.create { (observer) -> Disposable in
            print("generate str is in main thread: \(Thread.current.isMainThread)")
            observer.onNext("str1")
            observer.onNext("str2")
            observer.onNext("str3")
            observer.onCompleted()
            return Disposables.create()
        }
        
        let _ = rxData
                .subscribeOn(SerialDispatchQueueScheduler.init(qos: .userInitiated))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (str) in
                    print("receive str is in main thread: \(Thread.current.isMainThread)")
                    print("string: \(str)")
                }, onError: { (error) in
                    print("error: \(error)")
                }, onCompleted: {
                    print("completed")
                }) {
                    print("finished")
            }
        
    }

}

