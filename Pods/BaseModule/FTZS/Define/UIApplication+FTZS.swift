//
//  UIApplication+FTZS.swift
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

extension UIApplication: CustomAppInfo {
    public static func yjs_appID() -> String {
        return "1261299076"
    }
    
    public static func yjs_appName() -> String {
        #if TARGET_TTYY
        return "ttyy"
        #else
        return "zhuishuFree"
        #endif

    }
    
    public static func yjs_platformType() -> String {
        return "zhuishuFree"
    }
    
    @objc public static func yjs_productLine() -> String {
        // 1追书 2漫画岛 3开卷 4免费阅读广告(破解版) 5芒果阅读 6追书免费版（独立包）10饭团追书
        // 如果要修改，下面的方法也跟着改 ftzs_integerProductLine
        #if TARGET_TTYY
        return "26"
        #endif
        return "10"
    }
    
    public static func yjs_h5Version() -> String {
        // 8: 神策埋点
        return "8"
    }
    
    @objc public static func yjs_packageName() -> String {
        return "com.ifmoc.DouKouYueDu2"
    }
    
    public static func yjs_isTestFlight() -> Bool {
        return false
    }
}
