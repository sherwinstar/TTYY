//
//  YJSReqServiceManager.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation

public class YJSReqServiceManager: NSObject {
    var enableException = false
    public static let share = YJSReqServiceManager()
    
    private var allServicesDict = [String: Any]()
    private var lock = NSRecursiveLock()
    
    func registerService(service: Any?, implClass: AnyClass?) {
        assert(service != nil)
        assert(implClass != nil)
        guard let service = service else {
            return
        }
        guard let implClass = implClass else {
            return
        }
//        if !implClass.conforms(to: YJSReqServiceProtocol.Type) {
//            if enableException {
//                //TODO: 向外抛出错误
////                throw NSException(name: NSExceptionName(rawValue: NSExceptionName.internalInconsistencyException.rawValue), reason: "\(NSStringFromClass(implClass)) module does not comply with \(NSStringFromProtocol(service)) protocol", userInfo: nil) as! Error
//            }
//            return
//        }
        
        let serviceName = String(describing: service.self)
        
        if checkValidService(serviceName) {
            if enableException {
                //TODO: 向外抛出错误
            }
            return
        }
        
        
        let implClassName = NSStringFromClass(implClass)
        lock.lock()
        if serviceName.count > 0 && implClassName.count > 0 {
            allServicesDict[serviceName] = implClassName
        }
        lock.unlock()
    }
    
    public func createService(service: Any) -> AnyObject? {
        createService(service: service, isShouldCache: true)
    }
    
    public func createService(service: Any?, isShouldCache: Bool) -> AnyObject? {
        guard let service = service else {
            return nil
        }
        let serviceName = String(describing: service.self)
        
        if !checkValidService(serviceName) {
            if enableException {
                //TODO: 向外抛出错误
            }
            return nil
        }
        if isShouldCache {
            let implInstance = YJSReqServiceContext.share.getServiceInstance(serviceName)
            if implInstance != nil {
                return implInstance!
            }
        }
        
        guard let implClass = serviceImplClass(serviceName) as? YJSReqServiceProtocol.Type else {
            return nil
        }
        let implInstance: AnyObject?
        if implClass.singleton() {
            implInstance = implClass.share() as AnyObject
        } else {
            implInstance = implClass.init() as AnyObject
        }
        if isShouldCache {
            YJSReqServiceContext.share.addService(implInstance: implInstance!, serviceName: serviceName)
        }
        return implInstance
    }
    
    func getServiceInstanceFromServiceName(serviceName: String) -> AnyObject? {
        return YJSReqServiceContext.share.getServiceInstance(serviceName)
    }
    
    func removeServiceWithServiceName(serviceName: String) {
        YJSReqServiceContext.share.removeService(serviceName)
    }
}

private extension YJSReqServiceManager {
    func serviceImplClass(_ serviceName: String) -> AnyClass? {
        guard let implClassName = servicesDict()[serviceName] as? String else {
            return nil
        }
        return NSClassFromString(implClassName)
    }
    
    func checkValidService(_ serviceName: String) -> Bool {
        guard let implClassName = servicesDict()[serviceName] as? String else {
            return false
        }
        if implClassName.count > 0 {
            return true
        }
        return false
    }
    
    func servicesDict() -> [String: Any] {
        lock.lock()
        let dict = allServicesDict
        lock.unlock()
        return dict
    }
}
