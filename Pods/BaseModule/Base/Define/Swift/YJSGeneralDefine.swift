///
///  YJSGeneralDefine.swift
///  YouShaQi
///
///  Created by CuiLu on 2019/N/26.
///  Copyright © 2019 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
///

import Foundation
import UIKit

//MARK: - 系统版本
public var System_version_iOS10: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 10.0
}()
public var System_version_iOS11: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 11.0
}()
public var System_version_iOS12: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 12.0
}()
public var ystem_version_iOS13: Bool = {
    let version = (UIDevice.yjs_systemVersion() as NSString).floatValue
    return version >= 13.0
}()

//MARK: - 线程操作
public func doInGlobal(_ block:@escaping () -> ()) {
    DispatchQueue.global().async(execute: block)
}

public func doInMain(_ block:@escaping () -> ()) {
    DispatchQueue.main.async(execute: block)
}

public func doAfterInMain(seconds delay: CGFloat, _ workItem: @escaping () -> ()) {
    let mDelay = Int(delay * 1000)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(mDelay), execute: workItem)
}

//MARK: - Debug 打印
func debugLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        print(items, separator: separator, terminator: terminator)
    #endif
}

//MARK: - doIfSome
public extension Optional {
    public func doIfSome(_ closure: (Wrapped) -> ()) {
        if let w = self {
            closure(w)
        }
    }
}

//TODO:汤娟娟以下的测试配置应该移动到主工程去
////TODO:以下是测试配置区,请在上线前将全部的测试开关关闭!!!
////MARK: - 测试开关
//public let kIsZhuishuTesting : Bool = false
//public let kIsCuiLuTesting : Bool = false
//public let kIsQJayTesting : Bool = false
//public let kIsHellTesting : Bool = false
//public let kIsWangSYTesting : Bool = false
//public let kIsWangBingCongTesting : Bool = false
//public let kIsTJJTesting : Bool = false
