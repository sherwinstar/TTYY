//
//  YJSReqServiceContext.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation

class YJSReqServiceContext: NSObject, NSCopying {
    private var servicesByName: [String: AnyObject]
    static let share: YJSReqServiceContext = {
        let context = YJSReqServiceContext()
        return context
    }()
    
    override init() {
        servicesByName = [String: AnyObject]()
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let context = YJSReqServiceContext()
        return context
    }
    
    func addService(implInstance: AnyObject, serviceName: String) {
        YJSReqServiceContext.share.servicesByName[serviceName] = implInstance
    }
    
    func removeService(_ serviceName: String) {
        YJSReqServiceContext.share.servicesByName.removeValue(forKey: serviceName)
    }
    
    func getServiceInstance(_ serviceName: String) -> AnyObject? {
        return YJSReqServiceContext.share.servicesByName[serviceName]
    }
}
