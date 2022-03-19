//
//  DataRequest+Extensions.swift
//  YouShaQi
//
//  Created by Beginner on 2020/6/5.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import Alamofire

var kDataRequest_HostType = "kDataRequest_HostType"

extension DataRequest {
    var hostType: YJSRequestHostType {
        set {
            objc_setAssociatedObject(self, &kDataRequest_HostType, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &kDataRequest_HostType) as? YJSRequestHostType {
                return rs
            }
            return .outServer
        }
    }
}
