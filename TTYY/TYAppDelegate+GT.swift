//
//  TYAppDelegate+GT.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/10.
//

import Foundation
import UIKit

extension AppDelegate:GeTuiSdkDelegate, UNUserNotificationCenterDelegate {
    func registerGeTui() {
        GeTuiSdk.start(withAppId: kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self)
        
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 注册远程通知
        GeTuiSdk.registerRemoteNotification([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for byte in deviceToken {
          token += String(format: "%02X", byte)
        }
        UserDefaults.standard.setValue(token, forKey: "deviceToken")
    }
    
    @available(iOS 10.0, *)
    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable : Any], notificationCenter center: UNUserNotificationCenter?, response: UNNotificationResponse?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
      completionHandler?(.noData)
    }
    
    @available(iOS 10.0, *)
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.badge, .sound, .alert])
    }
    
    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
      
    }
    
    
    func geTuiSdkDidSendMessage(_ messageId: String, result: Int32) {
    }
    
    
    //MARK: - 开关设置
    
    /// [ GTSDK回调 ] SDK设置推送模式回调
    func geTuiSdkDidSetPushMode(_ isModeOff: Bool, error: Error?) {
    }
    
    /// [ GTSDK回调 ] SDK启动成功返回cid
    func geTuiSdkDidRegisterClient(_ clientId: String) {
        TYPushInfoHelper.shared.saveCid(clientId)
    }
    
    /// [ GTSDK回调 ] SDK运行状态通知
    func geTuiSDkDidNotifySdkState(_ aStatus: SdkStatus) {
      
    }
    
    /// [ GTSDK回调 ] SDK错误反馈
    func geTuiSdkDidOccurError(_ error: Error) {
        NSLog(error.localizedDescription)
    }
}
