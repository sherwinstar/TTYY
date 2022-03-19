//
//  YJSReqTestConfigServiceProtocol.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/15.
//

import Foundation

public protocol YJSReqTestConfigServiceProtocol: YJSReqServiceProtocol {
    //MARK: - 测试域名
    func testHostEnable(_ hostType: YJSRequestHostType) -> Bool
    
    func updateTestHostEnable(_ testHostEnable: Bool, forHostType hostType: YJSRequestHostType)
    
    func testHost(_ hostType: YJSRequestHostType) -> String
    
    func updateTestHost(_ testHost: String, forHostType hostType: YJSRequestHostType)
    
    //MARK: - 强制使用Http
    func isForceHttp() -> Bool
    
    func updateForceHttp(_ isForceHttp: Bool)
    
    //MARK: - 强制关闭HttpDNS
    func isForceDisabledHttpDNS() -> Bool
    
    func updateForceDisabledHttpDNS(_ isForceDisabledHttp: Bool)
    
    //MARK: - 强制关闭接口缓存，每次都获取最新数据
    func isForceDisabledInterfaceCache() -> Bool
    
    func updateForceDisabledInterfaceCache(_ isForceDisabledInterfaceCache: Bool)
}
