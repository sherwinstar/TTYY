//
//  AppDelegate.swift
//  TTYY
//
//  Created by Beginner on 2021/5/26.
//

import UIKit
import BaseModule
import YJSWebModule
import YJShareSDK
import AdSupport
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds);
        window?.backgroundColor = UIColor.white;
        finishLaunching(launchOptions)
        return true
    }
    
    func finishLaunching(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let privacy = TYCacheHelper.getCacheBool(for: kHasAgreePrivacyProtocolCacheKey)
        if privacy == nil || privacy == false {
            let storyboard = UIStoryboard.init(name: "LaunchScreenSplashBgImg", bundle: nil)
            let hc = storyboard.instantiateViewController(withIdentifier: kTYLaunchScreenSplashBgImgID)
            window?.rootViewController = hc
            window?.makeKeyAndVisible()
            
            let vc = TYPrivacyViewController();
            vc.agreeClosure = {
                if #available (iOS 14.5, *) {
                    let states = ATTrackingManager.trackingAuthorizationStatus
                    if states == .denied || states == .authorized {
                        self.performAtOnceWhenLaunch(launchOptions)
                        self.performInSubThreadWhenLaunch()
                        return;
                    }
                    vc.enterFirstGuide()
                    ATTrackingManager.requestTrackingAuthorization { status in
                        doInMain {
                            self.performAtOnceWhenLaunch(launchOptions)
                            self.performInSubThreadWhenLaunch()
                        }
                    }
                }
                
            }
            hc.addChild(vc)
            hc.view.addSubview(vc.view)
            performStartService()
        } else {
            performStartService()
            performAtOnceWhenLaunch(launchOptions)
            performInSubThreadWhenLaunch()
        }
    }
    
    func performStartService() {
        // 启动网络服务
        YJSSessionManager.share.startService()
        WebModule.startWebService(moduleProtocols: [TYWebToUser.self, TYWebToWeb.self, TYWebToLog.self, TYWebToShop.self], userProtocol: TYWebToUser.self)
        TYHuYanHelper.startPublisherRequest()
        TYOnlineParamsHelper.startService()
    }
    
    func performAtOnceWhenLaunch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        // 神策
        TYSTAHelper.startService(launchOptions)
        // 注册微信
        TYAppDelegateHelper.registerWeChat()
        TYAppDelegateHelper.registerBugly()
        TYAppDelegateHelper.registerTingYun()
        TYAppDelegateHelper.registerJD()
        TYAppDelegateHelper.registerUMeng()
        TYAppDelegateHelper.registerTaobao()
        /// 点击归因
        TYAppDelegateHelper.requestChannelInfo()
        // 判断登录状态
        TYLoginService.loginFromLaunch(completeHandler: nil)
        registerGeTui()
        changeRootController()
        TYSTAHelper.track(eventName: TYSTAEvent_customAppStart, properties: ["is_hotstart": true])
    }
    
    private func changeRootController() {
        let mainVC = TYTabBarVC();
        window?.rootViewController = mainVC;
        window?.makeKeyAndVisible();
    }
    
    func performInSubThreadWhenLaunch() {
        doInGlobal {
            YJSUMeng.uploadCountEvent(kUMAppLaunch, label: nil)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        TYThirdLoadingView.remveView()
        TYSTAHelper.track(eventName: TYSTAEvent_customAppStart, properties: ["is_hotstart": false])
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        ThirdLoginSDK.handleOpen(url)
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let ali = AlibcTradeSDK.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        if ali {
            return ali
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var optionsParams = [String: Any]()
        for e in options {
            optionsParams[e.key.rawValue] = e.value
        }
        let ali = AlibcTradeSDK.sharedInstance().application(app, open: url, options: optionsParams)
        if ali {
            return ali
        }
        ThirdLoginSDK.handleOpen(url)
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let host = userActivity.webpageURL?.host?.lowercased(), host == "th5.zhuishushenqi.com", let urlStr = userActivity.webpageURL?.absoluteString.lowercased(), !urlStr.isBlank {
            if urlStr.contains("wechat") {
                return ThirdLoginSDK.handleWxOpenUniversalLink(userActivity)
            } else {
                return false
            }
        }
        return false
    }
}

