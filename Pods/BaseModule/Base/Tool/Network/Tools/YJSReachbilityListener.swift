//
//  YJSReachbilityListener.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

public class YJSReachbilityListener {
    
    private class func service() -> YJSReqReachbilityServiceProtocol? {
        return YJSReqServiceManager.share.createService(service: YJSReqReachbilityServiceProtocol.self) as? YJSReqReachbilityServiceProtocol
    }
    
    public class func networkStatus() -> (status: ReachbilityStatus, statusStr: String) {
        return service()?.networkStatus() ?? (ReachbilityStatus.unknown, "未知")
    }
    
    public class func isReachable() -> Bool {
        return service()?.isReachable() ?? false
    }
    
    public class func isReachableViaWiFi() -> Bool {
        return service()?.isReachableViaWiFi() ?? false
    }
    
    public class func isReachableViaCellular() -> Bool {
        return service()?.isReachableViaCellular() ?? false
    }
    
    ///获取当前WIFI名字
    public class func currentWifiName() -> String {
        guard let wifiInterfaces = CNCopySupportedInterfaces() else {
            return "local"
        }
        
        guard let interfaceArr = CFBridgingRetain(wifiInterfaces) as? Array<String> else {
            return "local"
        }
        if interfaceArr.count > 0 {
            let interfaceName = interfaceArr[0] as CFString
            let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
            
            if (ussafeInterfaceData != nil) {
                guard let interfaceData = ussafeInterfaceData as? Dictionary<String, Any> else {
                    return "local"
                }
                guard let wifiName = interfaceData["SSID"] as? String, wifiName.count > 0 else {
                    return "local"
                }
                return wifiName
            }
        }
        return "local"
    }
}
