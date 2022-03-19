//
//  TYSTAHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/13.
//

import UIKit
import SensorsAnalyticsSDK
import BaseModule
import ReactiveCocoa

#if DEBUG
private let kServerURL = "https://endpoint.zhuishushenqi.com/sa?project=default"
private let kScheme = "sacaed657c"
#else
private let kServerURL = "https://endpoint.zhuishushenqi.com/sa?project=production"
private let kScheme = "sa51721f84"
#endif

private let productLine = 26

class TYSTAHelper: NSObject {
    class func startService(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let staEnable = TYOnlineParamsHelper.shared.onlineParamsModel?.thirdSDK?.staEnable, staEnable == false {
            return
        }
        // 初始化配置
        let options = SAConfigOptions(serverURL: kServerURL, launchOptions: launchOptions)
        // 开启全埋点，可根据需求进行组合
        options.autoTrackEventType = [.eventTypeAppStart, .eventTypeAppEnd, .eventTypeAppClick, .eventTypeAppViewScreen]
        options.enableVisualizedAutoTrack = true
        options.enableTrackAppCrash = true
        // 开启 App 打通 H5
        options.enableJavaScriptBridge = true
        #if DEBUG
        // SDK 开启log
        options.enableLog = false
        // 开发者模式下，一个小时上传一次数据
        options.flushInterval = 3600 * 1000
        options.flushBulkSize = 1000
        // 开发者模式下，手动上传按钮
        doAfterInMain(seconds: 1) {
            createView()
        }
        #endif
        // 初始化SDK
        SensorsAnalyticsSDK.start(configOptions: options)
        // 静态公共属性
        SensorsAnalyticsSDK.sharedInstance()?.registerSuperProperties(getSTAStaticSuperProperties())
        updateDynamicSuperProperties()
        //追踪激活事件，详见：https://sensorsdata.cn/manual/app_channel_tracking.html
        SensorsAnalyticsSDK.sharedInstance()?.trackInstallation("AppInstall")
        //打通 App 与 H5，详见：https://sensorsdata.cn/manual/app_h5.html
//        SensorsAnalyticsSDK.sharedInstance()?.addWebViewUserAgentSensorsDataFlag()
    }
    
    class func updateDynamicSuperProperties() {
        // 动态公共属性
        SensorsAnalyticsSDK.sharedInstance()?.registerDynamicSuperProperties({
            return getSTADynamicSuperProperties()
        })
    }
    
    class func getSTADynamicSuperProperties() -> [String: Any] {
        var params = [String: Any]()
        let userId = TYUserInfoHelper.getUserId()
        if !userId.isBlank {
            params["zs_login_id"] = userId
        }
        return params
    }
    
    /// 设置用户属性
    class func setUserProfile(_ profile: Any?, for key: String) {
        SensorsAnalyticsSDK.sharedInstance()?.setValue(profile, forKey: key)
    }
    
    class func track(eventName: String, properties: [String: Any]) {
        if let staEnable = TYOnlineParamsHelper.shared.onlineParamsModel?.thirdSDK?.staEnable, staEnable == false {
            return
        }
        if !eventName.isBlank, properties.count > 0 {
            SensorsAnalyticsSDK.sharedInstance()?.track(eventName, withProperties: properties)
        }
    }
    
    class func trackViewScreen(vc: UIViewController?, properties: [String: Any] ) {
        if let staEnable = TYOnlineParamsHelper.shared.onlineParamsModel?.thirdSDK?.staEnable, staEnable == false {
            return
        }
        if let controller = vc, properties.count > 0 {
            SensorsAnalyticsSDK.sharedInstance()?.trackViewScreen(controller, properties: properties)
        }
    }
    
    class func trackAppClick(view: UIView?, properties: [String: Any]) {
        if let staEnable = TYOnlineParamsHelper.shared.onlineParamsModel?.thirdSDK?.staEnable, staEnable == false {
            return
        }
        if let view = view, properties.count > 0 {
            SensorsAnalyticsSDK.sharedInstance()?.trackViewAppClick(view, withProperties: properties)
        }
    }
    
    class func ignoreAutoTrackViewControllers(_ vcs: [UIViewController]) {
        var vcNames = [String]()
        for vc in vcs {
            let name = NSStringFromClass(vc.classForCoder)
            vcNames.append(name)
        }
        SensorsAnalyticsSDK.sharedInstance()?.ignoreAutoTrackViewControllers(vcNames)
    }
    
    class func getSTACommonProperties() -> [String: Any] {
        var dic = [String: Any]()
        if let properties = SensorsAnalyticsSDK.sharedInstance()?.currentSuperProperties() as? [String: Any], properties.count > 0 {
            dic.merge(properties) { (_, new) in new }
        }
        let dynamicDic = getSTADynamicSuperProperties()
        if dynamicDic.count > 0 {
            dic.merge(dynamicDic) { (_, new) in new }
        }
        return dic
    }
}

private extension TYSTAHelper {
    class func createView() {
        let btnUpload = UIButton()
        UIApplication.shared.keyWindow?.addSubview(btnUpload)
        btnUpload.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview().offset(-100)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        btnUpload.setBackgroundColor(UIColor.init(white: 0.3, alpha: 0.6), for: .normal)
        btnUpload.layer.borderColor = UIColor.gray.cgColor
        btnUpload.layer.borderWidth = 1
        btnUpload.layer.cornerRadius = 25
        btnUpload.layer.masksToBounds = true
        btnUpload.titleLabel?.font = Font_System_IPadMul(15)
        btnUpload.setTitle("上传", for: .normal)
        btnUpload.sensorsAnalyticsIgnoreView = true
        btnUpload.rac_signal(for: .touchUpInside).subscribeNext { _ in
            SensorsAnalyticsSDK.sharedInstance()?.flush()
        }
    }
    
    /// 静态属性
    class func getSTAStaticSuperProperties() -> [String: Any] {
        var params = [String: Any]()
        params["platform"] = "1"
        params["product_line"] = "\(productLine)"
        return params
    }
}
