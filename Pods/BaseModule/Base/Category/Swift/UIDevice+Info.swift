//
//  UIDevice+Info.swift
//  YouShaQi
//
//  Created by Beginner on 2019/8/27.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import UIKit
import AdSupport
import CoreTelephony

extension UIDevice {
    //MARK: - 屏幕适配
    /// 屏幕宽高像素
    @objc class public func yjs_screenResolution() -> String {
        let rect = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let width = rect.width * scale
        let height = rect.height * scale
        return "\(width)*\(height)"
    }
    
    /// 屏幕的安全区域
    @objc class public func yjs_safeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            guard let safeAreaInsets = UIApplication.getWindow()?.safeAreaInsets else {
                return UIEdgeInsets.zero
            }
            return safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    /// 是否是全面屏
    @objc class public func yjs_isFullScreen() -> Bool {
        let safeAreaInsets = UIDevice.yjs_safeAreaInsets()
        return safeAreaInsets.bottom > 0
    }
    
    //MARK: - 获取系统版本号
    @objc class public func yjs_systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    //MARK: - 获取设备型号
    @objc class public func yjs_platform() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        return platform
    }
    
    @objc class public func yjs_platformString() -> String {
        let platform = yjs_platform()
        if platform == "iPhone1,1" { return "iPhone 2G"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,6" { return "iPhone X"}
        if platform == "iPhone11,2" { return "iPhone XS"}
        if platform == "iPhone11,4" { return "iPhone XS Max"}
        if platform == "iPhone11,6" { return "iPhone XS Max"}
        if platform == "iPhone11,8" { return "iPhone XR"}
        
        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
        return platform
    }
    
    /// 设备的唯一标示，自定义的idfa
    @objc class public func yjs_uniquelIdfa() -> String {
        return YJIdfaHelper.uniquelIdfa()
    }
    
    public class func yjs_idfaString() -> String {
        return YJIdfaHelper.idfaString()
    }
    
    /// 设备 mac 地址
    @objc class public func yjs_macString() -> String {
        return YJIdfaHelper.macString()
    }
    
    /// 获取运行商码
    class public func yjs_carrierCode() -> String {
        let telephonyInfo = CTTelephonyNetworkInfo()
        let carrier = telephonyInfo.subscriberCellularProvider
        return carrier?.mobileNetworkCode ?? ""
    }
    
    ///获取运营商信息(IMSI)
    class public func yjs_imsi() -> String {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        let mcc = carrier?.mobileCountryCode ?? ""
        let mnc = carrier?.mobileNetworkCode ?? ""
        let imsi = "\(mcc)\(mnc)"
        return imsi
    }
    
}
