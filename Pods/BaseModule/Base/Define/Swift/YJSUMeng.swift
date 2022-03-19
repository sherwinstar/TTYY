//
//  YJSUMeng.swift
//  BaseModule
//
//  Created by Admin on 2020/9/9.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

public struct YJSUMeng {
    /// 上传计数统计
    public static func uploadCountEvent(_ eventId: String, label: String?) {
        YJUMengWrapper.uploadCountEvent(withId: eventId, label: label)
    }
    
    /// 上传计算统计
    public static func uploadCalculateEvent(_ eventId: String, attributes: [String : String]?) {
        YJUMengWrapper.uploadCalculateEvent(withId: eventId, attributes: attributes)
    }
}
