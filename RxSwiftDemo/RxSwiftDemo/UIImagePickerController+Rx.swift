//
//  UIImagePickerController+Rx.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/29.
//  Copyright © 2019 jams. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit


extension Reactive where Base: UIImagePickerController {
    
    
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey : AnyObject]> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, a[1])
        })
    }
    
    public var didCancel: Observable<()> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map{ _ in () }
    }

}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
