//
//  YJSWebToModuleProtocol.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/3.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import WebKit

public typealias WebStrJson = [String : String]
public typealias WebJson = [String : Any]
public typealias WebCloseClosure = ((WebJson?) -> ()) // 回调一个自定义的json，里边带的是返回的时候需要调用的参数
public typealias WebCallBack = (String) -> () //jsString

// 传递给外部模块的上下文环境
@objc public class YJSWebContext: NSObject {
    public weak var fromVC: YJSWebContentVC?
    public weak var delegate: YJSWebContentDelegate?
    
    public init(fromVC: YJSWebContentVC?, delegate: YJSWebContentDelegate?) {
        self.fromVC = fromVC
        self.delegate = delegate
    }
}

@objc public enum ViewStateChange: Int {
    // 视图控制器生命周期
    case didLoad
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case didDealloc
    // 网页生命周期
    case webViewIntial
    case webBeginLoad
    case webDidFinishLoad
    case webDidFinishError
    
    var isWebState: Bool {
        switch self {
        case .webViewIntial, .webBeginLoad, .webDidFinishLoad, .webDidFinishError:
            return true
        default:
            return false
        }
    }
}

@objc public protocol YJSWebContentStateProtocol {
    // Web 运行的状态，根据这些状态，外部模块可以适时地做些处理
    @objc optional func viewStateChanged(webVC: YJSWebContentVC, changed: ViewStateChange)
}

@objc public protocol YJSWebStoreStateProtocol {
    // Web 运行的状态，根据这些状态，外部模块可以适时地做些处理
    @objc optional func viewStateChanged(webStore: YJSWebStoreVC, changed: ViewStateChange)
}


/// 处理h5需要同步回调的问题
@objc public protocol YJSWebSyncActionProtocol {
    /// 是否能处理方法 给同步方法调用
    @objc optional func canHandleAction(action: String) -> Bool
    /// 获取同步方法需要的数据
    @objc optional func getSyncInfo(action: String) -> String

}

//MARK: - 需要外部模块实现的协议
@objc public protocol YJSWebToModuleProtocol: YJSWebContentStateProtocol, YJSWebStoreStateProtocol, YJSWebSyncActionProtocol {
    
    static var moduleIdentifier: String { get }
    
    init(webVC: YJSWebContentVC)
    
    // 是否可以处理某 h5 调用
    func canHandleWebItem(webItem: YJSWebItem) -> Bool
    // 处理某 h5 调用
    @objc optional func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack)
    
    // 处理导航栏右边按钮，这个按钮来源有3种：其他模块配置的/h5回调配置的/Web模块自己设置的
    // 有需要时才会调用这个方法，不是点击按钮就会调用的
    @objc optional func handle(navItem: YJSWebNavBtnInnerType, webStore: YJSWebStoreVC)
}

//MARK: - 用户协议
// Web 需要知道的用户信息，用户信息应该做成弱业务模块，这样 Web 模块可以直接依赖
@objc public protocol YJSWebUserInfoProtocol {
    static func isLogin() -> Bool
    static func userId() -> String?
    static func userToken() -> String?
    static func userUniqueId() -> String?
    static func userGender() -> String?
    static func youngMode() -> Bool
    static func userPreferrce() -> [AnyHashable : Any]?
    static func goLogin(from parentVC: UIViewController)
    static var loginSucceedNotificationName: Notification.Name { get }
}
