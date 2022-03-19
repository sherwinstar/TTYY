//
//  TYAppDelegateHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/7.
//

import UIKit
import YJShareSDK
import Bugly
import BaseModule

class TYAppDelegateHelper: NSObject {
    
    /// 注册微信
    class func registerWeChat() {
//        WXApi.startLog(by: .detail) { log in
//            print("WeChatSDK " + log)
//        }
        ThirdLoginSDK.ssdkSetupWeChat(byAppId: kWeixinAppKey, appSecret: kWeixinSecret, universalLink: kWeixinUniversalLink)
//        WXApi.checkUniversalLinkReady { step, result in
//            print("WeChatSDK", step.rawValue, result.success, result.errorInfo, result.suggestion)
//        }
    }
    
    /// 注册bugly
    class func registerBugly() {
        let config = BuglyConfig()
        config.reportLogLevel = .warn
        Bugly.start(withAppId: kBuglyAppId, config: config)
        let deviceId = YJIdfaHelper.uniquelIdfa() ?? ""
        if !deviceId.isBlank {
            Bugly.setUserValue(deviceId, forKey: "deviceid")
        }
        if !TYUserInfoHelper.userIsLogedIn() {
            return
        }
        Bugly.setUserIdentifier(TYUserInfoHelper.getUserId())
        Bugly.setUserValue(TYUserInfoHelper.getUserName(), forKey: "username")
    }
    
    /// 注册tingyun
    class func registerTingYun() {
        if let tingyunEnable = TYOnlineParamsHelper.shared.onlineParamsModel?.thirdSDK?.tingyunSDKEnable, tingyunEnable == false {
            return
        }
        NBSAppAgent.start(withAppID: kTingYunAppId)
        let userId = TYUserInfoHelper.getUserId()
        if !userId.isBlank {
            NBSAppAgent.setUserIdentifier(userId)
        }
    }
    
    /// 初始化京东SDK
    class func registerGT() {
        
    }
    
    /// 初始化京东SDK
    class func registerJD() {
        KeplerApiManager.sharedKPService().asyncInitSdk(jdAppKey, secretKey: jdAppSecretKey) {
        } failedCallback: { error in
        }
    }
    
    /// 注册淘宝
    class func registerTaobao() {
        #if DEBUG
        AlibcTradeSDK.sharedInstance().setDebugLogOpen(true)
        #endif
        AlibcTradeSDK.sharedInstance().setIsvVersion(UIApplication.yjs_versionShortCode())
        AlibcTradeSDK.sharedInstance().setIsvAppName("TTYY")
        AlibcTradeSDK.sharedInstance().asyncInit {
        } failure: { _ in
        }

    }
    
    /// 注册友盟
    class func registerUMeng() {
        #if DEBUG
        UMConfigure.setLogEnabled(true)
        #endif
        UMConfigure.initWithAppkey(kUMAppKey, channel: "App Store")
        UMConfigure.setEncryptEnabled(true)
        if TYUserInfoHelper.userIsLogedIn() {
            MobClick.profileSignIn(withPUID: TYUserInfoHelper.getUserId())
        }
        UMCrashConfigure.setCrashCBBlock {
            if TYUserInfoHelper.userIsLogedIn() {
                return "userid:" + TYUserInfoHelper.getUserId()
            } else {
                return "device_imei:" + YJIdfaHelper.uniquelIdfa()
            }
        }
    }
    
    /// 请求归因接口 60005
    class func requestChannelInfo() {
        TYChannelHelper.shared.requestChannelInfo {
            TYAppDelegateHelper.uploadUserBaseBehavior()
        }
    }
    
    /// 请求统计接口 50207
    class func uploadUserBaseBehavior() {
        TYLogHelper.shared.uploadUserBaseBehavior(tag: .launch)
    }
}
