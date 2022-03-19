//
//  UIApplication+Info.swift
//  YouShaQi
//
//  Created by Beginner on 2019/8/27.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import UIKit

// 因为饭团的 FTZSTabBarVC 不继承自 UITabBarController，才不得已声明的协议
@objc public protocol YJContainerControllerProtocol {
    @objc func selectedViewController() -> UIViewController?
}

//MARK: - 包信息
extension UIApplication {
    /// App名称
    @objc public class func yjs_bundleDisplayName() -> String {
        return (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
    }
    
    /// target 名: YouShaQi
    @objc class public func yjs_bundleName() -> String {
        return (Bundle.main.infoDictionary!["CFBundleExecutable"] as? String) ?? ""
    }
    
    /// bundleId
    @objc class public func yjs_bundleId() -> String {
        return (Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String) ?? ""
    }
    
    /// 3位版本号
    @objc class public func yjs_versionShortCode() -> String {
        return (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    //每次发布前需要根据版本替换，并告知服务端
    //版本号base64再MD5
    @objc class public func yjs_publisherID() -> String {
        let version = yjs_versionShortCode()
        let data = version.data(using: .utf8)
        let result = data?.base64EncodedString(options: .lineLength64Characters).yj_MD5String()
        return result ?? ""
    }
    
    class public func yjs_bookApiPackageName() -> String {
        let bundleID = Bundle.main.bundleIdentifier
        return bundleID ?? ""
    }
    
    class public func yjs_versionShortCodeHasOneDot() -> String {
        let components = versionShortCode().components(separatedBy: ".")
        guard components.count > 1 else {
            return ""
        }
        var resultComponents = components.map { (component) -> String in
            switch component.count {
            case 1:
                return "00\(component)"
            case 2:
                return "0\(component)"
            default:
                return component
            }
        }
        resultComponents[0] = "\(components[0])."
        return resultComponents.toString(joinBy: "")
    }
}

//MARK: - 视图信息
extension UIApplication {
    /// 当前的 keyWindow
    class public func getWindow() -> UIWindow? {
        guard let optional = UIApplication.shared.delegate?.window, let window = optional else {
            return nil
        }
        return window
    }
    
    /// 最顶层的导航栏
    public class func getCurrentNav() -> UINavigationController? {
        guard let window = UIApplication.shared.windows.last as? UIWindow else {
            return nil
        }
        let root = getWindow()?.rootViewController
        return p_getCurrentNav(from: root)
    }
    
    /// 位于 vc 之上的最顶层导航栏
    private class func p_getCurrentNav(from vc: UIViewController?) -> UINavigationController? {
        var cur = vc
        while true {
            if let tab = cur as? UITabBarController {
                cur = tab.selectedViewController
            } else if let nav = cur as? UINavigationController {
                if let parent = nav.presentedViewController {
                    cur = parent
                } else {
                    cur = nav.topViewController
                }
            } else if let viewController = cur {
                if let parent = viewController.presentedViewController {
                    cur = parent
                } else {
                    return viewController.navigationController
                }
            } else { // nil
                return nil
            }
        }
    }
    
    /// 最顶层视图控制器
    public class func getCurrentVC() -> UIViewController? {
        guard let window = getWindow() else {
            return nil
        }
        let root = window.rootViewController
        return p_getCurrentVC(from: root)
    }
    
    /// 位于 root 之上的最顶层视图控制器
    private class func p_getCurrentVC(from root: UIViewController?) -> UIViewController? {
        var cur = root
        while true {
            if let child = cur?.presentedViewController {
                cur = child
            } else if let tab = cur as? UITabBarController {
                cur = tab.selectedViewController
            } else if let nav = cur as? UINavigationController {
                cur = nav.topViewController
            } else if let customContainer = cur as? YJContainerControllerProtocol {
                if let child = customContainer.selectedViewController() {
                    cur = child
                } else {
                    return cur
                }
            } else {
                return cur
            }
        }
    }
}

//MARK: - 跳转
extension UIApplication {
    public static func customOpenUrlStr(_ urlStr: String) {
        var newUrlStr = urlStr.contains("/mac") ?
            "\(urlStr)&idfa=\(UIDevice.yjs_idfaString())&mac=\(UIDevice.yjs_macString())&random=\(Date().timeIntervalSince1970)" :
            urlStr
        newUrlStr.yjs_queryEncodedURLString()
            .flatMap { URL(string: $0) }
            .doIfSome {
                UIApplication.shared.open($0, options: [:], completionHandler: nil)
            }
    }
}

//MARK: - 通知
extension UIApplication {
    private typealias PushStateGetter = (Bool)->()
    @objc public static func jumpToSystemPushConfig(_ completion: ((Bool)->())?) {
        let url = URL(string: UIApplication.openSettingsURLString)
        url.doIfSome {
            UIApplication.shared.open($0, options: [:], completionHandler: nil)
        }
        if let completion = completion {
            listenPushState(completion)
        }
    }
    
    private static func listenPushState(_ completion: @escaping PushStateGetter) {
        let app = UIApplication.shared
        let name: Notification.Name = UIApplication.willEnterForegroundNotification
        var observers: [NSObjectProtocol] = [] // 如果直接用 observer，闭包无法捕获到正确的值
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: OperationQueue.main) { (notification) in
            observers.first.doIfSome {
                NotificationCenter.default.removeObserver($0)
            }
            observers.removeAll()
            asyGetPushSettings { (isEnable) in
                completion(isEnable)
            }
        }
        observers.append(observer)
    }
    
    @objc public static func getPushSettings() -> Bool {
        let semasphore = DispatchSemaphore(value: 0)
        var isEnabled = false
        asyGetPushSettings {
            isEnabled = $0
            semasphore.signal()
        }
        semasphore.wait()
        return isEnabled
    }
    
    private static func asyGetPushSettings(_ completion: @escaping PushStateGetter) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

public protocol CustomAppInfo {
    static func yjs_appID() -> String
        
    static func yjs_appName() -> String
        
    static func yjs_platformType() -> String
        
    static func yjs_productLine() -> String
        
    static func yjs_h5Version() -> String
        
    static func openAppstore()

    static func yjs_packageName() -> String
        
    static func yjs_isTestFlight() -> Bool
}

extension CustomAppInfo {
    public static func openAppstore() {
        let urlStr = "itms-apps://itunes.apple.com/app/id\(Self.yjs_appID())"
        UIApplication.customOpenUrlStr(urlStr)
    }
}

