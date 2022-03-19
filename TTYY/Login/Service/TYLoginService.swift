//
//  TYLoginService.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/7.
//

import UIKit
import BaseModule
import YJShareSDK
import Alamofire

class TYLoginService: NSObject {
    
    /// 获取微信授权
    class func getWXAuthorization(completeHandler:@escaping (Bool, [String: Any]?) -> Void) {
        ThirdLoginSDK.authorize(.SS, settings: [:]) { state, user, error in
            if let sdkUser = user, state == .success {
                let uid = sdkUser.uid ?? ""
                let token = sdkUser.credential.token ?? ""
                let params = ["access_token": token, "openid": uid]
                completeHandler(true, params)
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 微信登录
    class func loginWX(params: [String: Any], completeHandler:@escaping (Bool) -> Void) {
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/Login", params: params).responseJSON { isSuccess, result, error, _ in
            handleLoginAfterData(isSuccess, errorMsg: error?.localizedDescription, result: result, completeHandler: completeHandler)
        }
    }
    
    /// 苹果登录
    class func loginApple(params: [String: Any], completeHandler:@escaping (Bool) -> Void) {
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/AppleLogin", params: params).responseJSON { isSuccess, result, error, _ in
            handleLoginAfterData(isSuccess, errorMsg: error?.localizedDescription, result: result, completeHandler: completeHandler)
        }
    }
    
    /// 处理登录后的数据
    /// - Parameters:
    ///   - result: 用户信息
    ///   - completeHandler: 回调
    class func handleLoginAfterData(_ isSuccess: Bool, errorMsg: String?, result: [String: Any], completeHandler:@escaping (Bool) -> Void) {
        if let ok = result["ok"] as? Bool, ok, let data = result["data"] as? [String: Any] {
            let model = data.kj.model(TYUserInfoModel.self)
            TYUserInfoHelper.saveUserInfo(model)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
            TYAppDelegateHelper.registerBugly()
            YJSUMeng.uploadCountEvent(kUMAppUserLogin, label: nil)
            loginSTA(isSuccess: true, errorMsg: nil)
            completeHandler(true)
        } else {
            TYUserInfoHelper.removeUserInfo()
            var failMessage = "登录失败！"
            if let msg = result["msg"] as? String, !msg.isBlank {
                failMessage = msg
            } else if let msg = errorMsg, !msg.isBlank {
                failMessage = msg
            }
            UIApplication.getCurrentVC()?.showToast(msg: failMessage)
            loginSTA(isSuccess: false, errorMsg: failMessage)
            completeHandler(false)
        }
    }
    
    /// 登录后的埋点
    class func loginSTA(isSuccess: Bool, errorMsg: String?) {
        var params = [String: Any]()
        params["is_success"] = isSuccess
        if let msg = errorMsg, !msg.isBlank {
            params["error_reason"] = msg
        }
        TYSTAHelper.track(eventName: TYSTAEvent_userLogin, properties: params)
    }
    
    /// 登录，给已经有token的时候使用
    class func loginFromLaunch(completeHandler: ((Bool) -> Void)?) {
        if !YJSReachbilityListener.isReachable() {
            return
        }
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            TYUserInfoHelper.removeUserInfo()
            completeHandler?(false)
            return
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/UserInfo", params: ["token": token]).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, let data = result["data"] as? [[String: Any]], let modelDict = data.first {
                let model = modelDict.kj.model(TYUserInfoModel.self)
                TYUserInfoHelper.saveUserInfo(model)
                completeHandler?(true)
            } else {
                TYUserInfoHelper.removeUserInfo()
                var failMessage = "登录失败！"
                if let msg = result["msg"] as? String, !msg.isBlank {
                    failMessage = msg
                }
                UIApplication.getCurrentVC()?.showToast(msg: failMessage)
                completeHandler?(false)
            }
        }
    }
    
    /// 绑定邀请码
    class func bindPromoter(code: String, completeHandler:@escaping (Bool, String?) -> Void) {
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            completeHandler(false, "请重新登录后绑定")
            return
        }
        let params = ["token": token, "primoterId": code]
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/bindPromoter", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess {
                completeHandler(true, nil)
            } else {
                var failMsg = error?.localizedDescription ?? ""
                if let msg = result["msg"] as? String, !msg.isBlank {
                    failMsg = msg
                }
                completeHandler(false, failMsg)
            }
        }
    }
    
    /// 绑定支付宝
    /// - Parameters:
    ///   - account: 账号
    ///   - idCard: 身份证号
    ///   - name: 姓名
    class func bindAlipay(account: String, idCard: String, name: String,completeHandler:@escaping (Bool, String?) -> Void) {
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            completeHandler(false, "请重新登录后绑定")
            return
        }
        var params = [String: Any]()
        params["token"] = token
        params["aliAccount"] = account
        params["idCardnum"] = idCard
        params["realName"] = name
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/bindAliPay", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess {
                completeHandler(true, nil)
            } else {
                var failMsg = error?.localizedDescription ?? ""
                if let msg = result["msg"] as? String, !msg.isBlank {
                    failMsg = msg
                }
                completeHandler(false, failMsg)
            }
        }
    }
}
