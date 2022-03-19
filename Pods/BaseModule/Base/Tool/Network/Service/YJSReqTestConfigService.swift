//
//  YJSReqTestConfigService.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/15.
//

import Foundation
import Cache

class YJSReqTestConfigService: NSObject, YJSReqTestConfigServiceProtocol {
    static func singleton() -> Bool {
        return true
    }
    
    static func share() -> Self {
        return YJSReqTestConfigService() as! Self
    }
    
    required override init() {
        super.init()
    }
    
    private lazy var testHostConfigCache: Storage<String> = {
        let diskConfig = DiskConfig(name: "com.yjn.test.host.config.string")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: String.self))
        return cache
    }()
    
    private lazy var testHostEnableConfigCache : Storage<Bool> = {
        let diskConfig = DiskConfig(name: "com.yjn.test.host.enable.config.string")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Bool.self))
        return cache
    }()
    
    func testHostEnable(_ hostType: YJSRequestHostType) -> Bool {
        do {
            let enable = (try testHostEnableConfigCache.entry(forKey: hostType.rawValue)).object
            return enable
        } catch {
            return false
        }
    }
    
    func updateTestHostEnable(_ testHostEnable: Bool, forHostType hostType: YJSRequestHostType) {
        do {
            try testHostEnableConfigCache.setObject(testHostEnable, forKey: hostType.rawValue)
        } catch {
            
        }
    }
    
    func testHost(_ hostType: YJSRequestHostType) -> String {
        do {
            let enable = (try testHostConfigCache.entry(forKey: hostType.rawValue)).object
            return enable
        } catch {
            return ""
        }
    }
    
    func updateTestHost(_ testHost: String, forHostType hostType: YJSRequestHostType) {
        do {
            try testHostConfigCache.setObject(testHost, forKey: hostType.rawValue)
        } catch {
            
        }
    }
    
    //强制使用Http
    func isForceHttp() -> Bool {
        do {
            let enable = (try testHostEnableConfigCache.entry(forKey: "test_force_http")).object
            return enable
        } catch {
            return false
        }
    }
    
    func updateForceHttp(_ isForceHttp: Bool) {
        do {
            try testHostEnableConfigCache.setObject(isForceHttp, forKey: "test_force_http")
        } catch {
            
        }
    }
    //强制关闭HttpDNS
    func isForceDisabledHttpDNS() -> Bool {
        do {
            let enable = (try testHostEnableConfigCache.entry(forKey: "test_force_disabled_httpDns")).object
            return enable
        } catch {
            return false
        }
    }
    
    func updateForceDisabledHttpDNS(_ isForceDisabledHttp: Bool) {
        do {
            try testHostEnableConfigCache.setObject(isForceDisabledHttp, forKey: "test_force_disabled_httpDns")
        } catch {
            
        }
    }
    
    //强制关闭接口缓存，每次都获取最新数据
    func isForceDisabledInterfaceCache() -> Bool {
        do {
            let enable = (try testHostEnableConfigCache.entry(forKey: "test_force_disabled_InterfaceCache")).object
            return enable
        } catch {
            return false
        }
    }
    
    func updateForceDisabledInterfaceCache(_ isForceDisabledInterfaceCache: Bool) {
        do {
            try testHostEnableConfigCache.setObject(isForceDisabledInterfaceCache, forKey: "test_force_disabled_InterfaceCache")
        } catch {
            
        }
    }
}
