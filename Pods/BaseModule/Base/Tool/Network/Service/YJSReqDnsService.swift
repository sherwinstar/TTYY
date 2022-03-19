//
//  YJSReqDnsService.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/15.
//

import Foundation
#if !TARGET_TTYY
import AlicloudHttpDNS
#endif

class YJSReqDnsService: NSObject, YJSReqDnsServiceProtocol {
    static func singleton() -> Bool {
        return true
    }
    
    static func share() -> Self {
        return YJSReqDnsService() as! Self
    }
    
    private var dnsHosts: [String] = [String]()
    
    required override init() {
        super.init()
    }

    func startService() {
        #if !TARGET_TTYY
        let kAliAccountID = 185442
        let kAliSecertKey = "48495907c116dbf992406902b7e15208"
        guard let httpDns = HttpDnsService(accountID: Int32(kAliAccountID), secretKey: kAliSecertKey) else {
            return
        }
        httpDns.setPreResolveHosts(dnsHosts)
        httpDns.delegate = self
        httpDns.setExpiredIPEnabled(true)
        httpDns.setPreResolveAfterNetworkChanged(true)
        httpDns.setHTTPSRequestEnabled(false)
        httpDns.setLogEnabled(true)
        #endif
    }
    
    func appendDNSHosts(_ hosts: [String]) {
        for host in hosts {
            if dnsHosts.contains(host) {
                continue
            }
            dnsHosts.append(host)
        }
        #if !TARGET_TTYY
        HttpDnsService.sharedInstance()?.setPreResolveHosts(dnsHosts)
        #endif
    }
    
    func updateDNSHosts(_ hosts: [String]) {
        dnsHosts = hosts
        #if !TARGET_TTYY
        HttpDnsService.sharedInstance()?.setPreResolveHosts(dnsHosts)
        #endif
    }
    
    func getHostIP(_ host: String) -> String {
        var usingAliHttpDns = false
        #if TARGET_ZSSQ
        usingAliHttpDns = YJSOnlineParamsHelper.shared.params?.network.usingAlihttpdns ?? false
        #endif
        if usingAliHttpDns == false {
            return host
        }
        #if TARGET_TTYY
        return host
        #else
        guard let ip = HttpDnsService.sharedInstance()?.getIpByHostAsync(host) else {
            return host
        }
        if ip.isBlank {
            return host
        }
        return ip
        #endif
    }
    
    private func isUsedProxy() -> Bool {
        guard let proxy = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() else {
            return false
        }
        guard let dict = proxy as? [String: Any] else {
            return false
        }
        // 有时候未设置代理dictionary也不为空，而是一个空字典
        guard let HTTPProxy = dict["HTTPProxy"] as? String else {
            return false
        }
        if(HTTPProxy.count>0){
            return true;
        }
        return false;
    }
}
#if !TARGET_TTYY
extension YJSReqDnsService: HttpDNSDegradationDelegate {
    //MARK: - DNS代理
    public func shouldDegradeHTTPDNS(_ hostName: String!) -> Bool {
        let testService = YJSReqServiceManager.share.createService(service: YJSReqTestConfigServiceProtocol.self) as? YJSReqTestConfigServiceProtocol
        if let service = testService, service.isForceDisabledHttpDNS() {
            return false
        }
        // 根据HTTPDNS使用说明，存在网络代理情况下需降级为Local DNS
        if isUsedProxy() {
            return true
        }
        // 在需要dns服务之列的域名，通过HTTPDNS进行解析
        if dnsHosts.contains(hostName) {
            return false
        }
        return true
    }
}
#endif
