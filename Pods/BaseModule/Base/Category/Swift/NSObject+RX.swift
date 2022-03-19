//
//  NSObject+RX.swift
//  BaseModule
//
//  Created by Admin on 2020/9/4.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import RxSwift

//MARK: - DisposeBag
extension NSObject {
    static var objectDisposeBagKey: String = "NSObject.DisposeBagKey"
    public var disposeBag: DisposeBag {
        get {
            if let bag = objc_getAssociatedObject(self, &(NSObject.objectDisposeBagKey)) as? DisposeBag {
                return bag
            }
            let bag = DisposeBag()
            disposeBag = bag
            return bag
        }
        set {
            objc_setAssociatedObject(self, &(NSObject.objectDisposeBagKey), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
