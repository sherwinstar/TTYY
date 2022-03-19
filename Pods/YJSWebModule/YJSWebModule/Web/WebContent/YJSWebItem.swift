//
//  YJSWebItem.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/4.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import MJExtension

public typealias JSCallBack = String

// 这个类完全是为了存储 h5 调用客户端方法时给的数据
@objc(YJSWebItem)
//MARK: - 存储数据
@objcMembers public class YJSWebItem: NSObject {
    // h5 给的原始数据是：funcName/queryDic，paramDic 是 queryDic 中的 param
    public var funcName: String
    public var queryDic: WebStrJson?
    public var paramDic: WebJson?
    
    public init(funcName: String, query: WebStrJson?, param: WebJson?) {
        self.funcName = funcName
        queryDic = query
        paramDic = param
    }
}

//MARK: - paramDic 中的内容
extension YJSWebItem {
    /*
     跳转事件中，h5给的参数是: jumpType 只有 webview/native/safari
     pageType: native 表示要跳转的页面，webview 时大部分时候都为空，目前我知道的有值的有：书单详情页
     link: url，webview/safari 时有效
     idValue: 比如跳转书单详情页时，书单ID会放在这里
     jump 会把 native 的各个页面类型提升到 jumpType 同级的位置，方便使用
     */
    // 这些是 paramDic 中提取出来的参数与
    public var jumpTypeStr: String? {
        paramDic?.getStrValue("jumpType") // webview/native/safari
    }
    public var pageType: String? {
        paramDic?.getStrValue("pageType")
    }
    public var title: String? {
        paramDic?.getStrValue("title")
    }
    public var link: String? {
        paramDic?.getStrValue("link")
    }
    public var idValue: String? {
        paramDic?.getStrValue("id")
    }
    public var sourceType: String? {
        paramDic?.getStrValue("sourceType")
    }
    
    #if TARGET_TTYY
    /// 天天有余，跳转的第三方
    public var productTypeStr: String? {
        paramDic?.getStrValue("type")
    }
    /// 天天有余，跳转第三方的url
    public var productUrlStr: String? {
        paramDic?.getStrValue("url")
    }
    #endif
    
    public var jump: JumpType? {
        jumpTypeStr.flatMap {
            switch $0 {
            case "webview":
                return .webview
            case "native":
                return pageType.flatMap { JumpType(rawValue: $0) }
            case "safari":
                return .safari
            default:
                return nil
            }
        }
    }
    
    public var webPageType: YJSStoreType {
        pageType.flatMap {
            YJSStoreType.fromRaw($0)
        } ?? .none
    }
}

//MARK: - js 回调
extension YJSWebItem {
    /*
     从 queryDic/paramDic 中 callback 中取出来的
     一般情况下是在 queryDic，但是通过 ScriptMessage 方式注入的方法，callback 是在 paramDic 中的
     */
    public var jsCallback: JSCallBack? {
        queryDic?.getStrValue("callback") ?? paramDic?.getStrValue("callback")
    }
    // 从 queryDic 中 param 中取出来的，有时候有值，需要在调用 jscallback 时传递进去
    public var jsCallbackParamStr: String? {
        queryDic?.getStrValue("param")
    }
    
    // 拼接完整的js回调代码，如果需要将自定义参数和h5给的默认参数拼在一起，需要在外面处理
    public func jsStr(_ paramStr: String? = nil) -> String? {
        guard let method = jsCallback else {
            return nil
        }
        if let ps = paramStr {
            return "\(method)(\(ps))"
        } else if let defaultPs = jsCallbackParamStr {
            return "\(method)(\(defaultPs))"
        } else {
            return "\(method)()"
        }
    }
}

//MARK: - 神策
extension YJSWebItem {
    public enum WebItemSeParamKey {
        case sensors
        case value
        case params
    }
    // 神策的参数，从 paramDic 的 指定key 中取出，并过滤掉 -1, null, <null>， -1是跟h5约定的要移除的，后两个是安全判断
    // 常用的 key 有：sensors, value
    public func seParams(_ key: WebItemSeParamKey = .params) -> WebJson {
        let sensorDic: WebJson?
        switch key {
        case .params:
            sensorDic = self.paramDic
        case .sensors:
            sensorDic = self.paramDic?["sensors"] as? WebJson
        case .value:
            sensorDic = (self.paramDic?["value"] as? String).flatMap { $0.mj_JSONObject() } as? WebJson
        }
        guard let sensor = sensorDic else {
            return [:]
        }

        return sensor.reduce(into: [:]) { (result, next) in
            if let strValue = next.value as? String {
                if ["-1", "null", "<null>"].contains(strValue) {
                    return
                } else {
                    result[next.key] = next.value
                }
            } else if let _ = next.value as? NSNumber {
                result[next.key] = next.value
            }
        }
    }
}

extension YJSWebItem {
    public enum JumpType: String {
        case webview // 网页
        case bookDetail
        case cleanBookDetail
        case login
        case monthlyPay // 开通包月
        case baseRecharge // 充值页面
        case personalCenter // 我
        case tasks // 绑定手机号后的回调
        case personalinfo // 跳转到个人信息页面
        case post // 帖子详情页，参数帖子ID：id
        case bookShortage // 书荒首页
        case account // 我的账户
        case search
        case category
        case createBookList
        case bookShortageQuestion
        case bookShortageAnswer
        case createBookShortageQuestion
        case createBookShortageAnswer
        case bookReview
        case createBookReview
        case createPost
        case reader
        case bookListComment
        case bookListEdit // 目前只有饭团有
        case people // 社区个人主页
        case safari
        case randomRead //随机看书
        case restoreVipPay
        case communityPersonalHomepage //社区个人主页
        case bookShortageIndex //书荒首页
        case localBookSpace // 本地书籍
        
        #if TARGET_TTYY
        case setting // 设置
        case alipay_withdraw_setting // 提现账户设置
        case join_partner  // 加入合伙人
        case bind_invite_code // 绑定邀请码
        case product_detail // 商品详情页
        case optimization // 优选
        case game_center // 游戏
        #endif
        
        func needsLogin() -> Bool {
            let logins: [JumpType] = [.bookListComment, .monthlyPay, .account, .personalCenter, .baseRecharge, .restoreVipPay, .personalinfo]
            return logins.contains(self)
        }
        
    }
}
