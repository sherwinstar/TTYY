//
//  YJSWebNavItem.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/5.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation

class YJSWebNavBtnModel: NSObject {
    // 只支持要么文字要么图片的按钮，不支持图文的
    var title: String?
    var imgName: String?
    var innerType: YJSWebNavBtnInnerType?
    var handler: (() -> ())?
    var needsLogin: Bool
    
    init(title: String?, needsLogin: Bool, handler: (() -> ())?) {
        self.title = title
        self.handler = handler
        self.needsLogin = needsLogin
    }
    
    init(imgName: String?, needsLogin: Bool, handler: (() -> ())?) {
        self.imgName = imgName
        self.handler = handler
        self.needsLogin = needsLogin
    }
    
    init(innerType: YJSWebNavBtnInnerType) {
        self.innerType = innerType
        self.needsLogin = innerType.needsLogin
    }
}

// 内置的 web 导航栏按钮类型
@objc public enum YJSWebNavBtnInnerType: Int {
    // WebStore 中用的
    case log
    case help
    // WebEvent 中用的
    case link
    case share
    case refresh
    case back //返回
    
    // 像 log, share 这样很短小的名字，来自于 h5 的定义
    public static func from(_ str: String?) -> YJSWebNavBtnInnerType? {
        switch str {
        case "log":
            return .log
        case "help":
            return .help
        case "link":
            return .link
        case "share":
            return .share
        case "refresh":
            return .refresh
        default:
            return nil
        }
    }
    
    public func imgName() -> String {
        switch self {
        case .log:
            return "shoutu_icon_detail_20_20_red"
        case .help:
            return "shoutu_icon_qa_20_20"
        case .link:
            return "web_nav_help"
        case .share:
            return "web_nav_share"
        case .refresh: // 刷新页面
            return "web_nav_refresh"
        case .back:
            return "nav_back_red"
        }
    }
    
    public var needsLogin: Bool {
        return false
    }
}
