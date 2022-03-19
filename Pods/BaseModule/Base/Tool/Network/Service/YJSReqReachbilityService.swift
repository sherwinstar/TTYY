//
//  YJSReqReachbilityService.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

public let kNotiNetworkStatusChanged = Notification.Name("kNotiNetworkStatusChanged")

class YJSReqReachbilityService: NSObject, YJSReqReachbilityServiceProtocol {
    private var reachabilityManager: NetworkReachabilityManager?
    
    static func singleton() -> Bool {
        return true
    }
    
    static func share() -> Self {
        return YJSReqReachbilityService() as! Self
    }
    
    required override init() {
        super.init()
    }
    
    func startService() {
        reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")
        guard let _ = reachabilityManager else {
            return
        }
        reachabilityManager?.startListening(onQueue: DispatchQueue.main) { (status) in
            switch status {
            case .unknown:
                print("网络状态变化：未知")
            case .reachable(.ethernetOrWiFi):
                print("网络状态变化：WIFI")
            case .reachable(.cellular):
                print("网络状态变化：蜂窝数据")
            case .notReachable:
                print("网络状态变化：无网络")
            }
            NotificationCenter.default.post(name: kNotiNetworkStatusChanged, object: nil)
        }
    }
    
    func networkStatus() -> (status: ReachbilityStatus, statusStr: String) {
        guard let status = reachabilityManager?.status else {
            return (.unknown, "未知")
        }
        switch status {
        case .unknown:
            return (.unknown, "未知")
        case .reachable(.ethernetOrWiFi):
            return (.wifi, "WIFI")
        case .reachable(.cellular):
            return (.cellular, "蜂窝数据")
        case .notReachable:
            return (.notReachable, "无网络")
        }
    }
    
    func isReachable() -> Bool {
        return networkStatus().status == .wifi || networkStatus().status == .cellular
    }
    
    func isReachableViaWiFi() -> Bool {
        return networkStatus().status == .wifi
    }
    
    func isReachableViaCellular() -> Bool {
        return networkStatus().status == .cellular
    }
}
