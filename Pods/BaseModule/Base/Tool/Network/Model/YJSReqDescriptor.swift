//
//  YJSReqDescriptor.swift
//  YouShaQi
//
//  Created by Beginner on 2019/7/4.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import Alamofire
import YJEncryptSwift

public typealias responseCompletionHandler = (Bool, Dictionary<String, Any>, Error?, DataRequest) -> Void

public class YJSReqDescriptor {
    /// 默认超时时间
    static let defaultTimeOut: TimeInterval = 25.0
    /// 协议: http、https、ftp...
    var scheme: String {
        get {
            //是否强制只用HTTP
            let testService = YJSReqServiceManager.share.createService(service: YJSReqTestConfigServiceProtocol.self) as? YJSReqTestConfigServiceProtocol
            if let service = testService, service.isForceHttp() {
                return "http"
            }
            //在线参数是否允许使用HTTPS
            var isHttpsEnabled = false
            #if TARGET_ZSSQ
            isHttpsEnabled = YJSOnlineParamsHelper.shared.params?.network.usingHttps ?? false
            #endif
            
            if isHttpsEnabled && hostModel.isSupportHttps {
                return "https"
            }
            return "http"
        }
    }
    /// 域名类型
    var hostType = YJSRequestHostType.outServer
    /// 域名信息
    var hostModel = YJSReqHostModel(.outServer)
    /// 接口地址
    var path = ""
    /// 超时时间
    var timeout = defaultTimeOut
    /// 请求头
    fileprivate(set) var customHeader: [String:String] = [:]
    /// 请求参数
    var params: [String : Any]?
    /// formData参数
    var formData: MultipartFormData?
    /// 请求方式: post、get、put、delete...
    var method = HTTPMethod.get
    /// 是否是鉴权加密请求
    var isEncrypt = false
    /// 参数的 encoding 方式
    var parameterEncoding: ParameterEncoding?
    
    init(_ hostType: YJSRequestHostType, method: HTTPMethod, path: String, params: [String : Any]? = nil, formData: MultipartFormData? = nil) {
        self.hostType = hostType
        self.method = method
        self.path = path
        self.params = params
        self.formData = formData
    }
    
    //拼接URL
    func composeUrl() -> String {
        handleReqDescriptor()
        if hostModel.type == .outServer {
            return path
        }

        var url : String = ""
        if hostModel.isSupportDns {
            url.append(contentsOf: "\(scheme)://\(hostModel.curIp())")
            customHeader["host"] = hostModel.curHostString()
        } else {
            url.append(contentsOf: "\(scheme)://\(hostModel.curHostString())")
        }
        
        let pathHeadedWithSplash = path.hasPrefix("/")
        if pathHeadedWithSplash {
            url.append(contentsOf: path)
        } else {
            url.append(contentsOf: "/\(path)")
        }
        if isEncrypt {
            let third_token = YJEncryptUtilsSwift.getPermissionsToken()
            if !third_token.isBlank {
                params?["third-token"] = third_token
            }
        }
        let testService = YJSReqServiceManager.share.createService(service: YJSReqTestConfigServiceProtocol.self) as? YJSReqTestConfigServiceProtocol
        if let service = testService, service.isForceDisabledInterfaceCache() {
            let timestamp = Int(Date().timeIntervalSince1970)
            params?["forceTimestamp"] = "\(timestamp)"
        }
        return url
    }
    
    func handleReqDescriptor() {
        if hostType != .outServer {
            guard let service = YJSReqServiceManager.share.createService(service: YJSReqPollHostServiceProtocol.self) as? YJSReqPollHostServiceProtocol else {
                    return
                }
            hostModel = service.getHostModel(forType: hostType)
        }
            
        addCommonHeader()
        
        guard let service = YJSReqServiceManager.share.createService(service: YJSReqDnsServiceProtocol.self) as? YJSReqDnsServiceProtocol else {
            return
        }
        let listHost = hostModel.pollHosts + [hostModel.curHostString()]
        service.appendDNSHosts(listHost)
    }
}

extension YJSReqDescriptor {
    func addCommonHeader() {
        if hostType == .outServer {
            return
        }
        var headers = customHeader
        if headers["X-Device-Id"]?.isBlank ?? true {
            headers.updateValue(UIDevice.yjs_uniquelIdfa(), forKey: "X-Device-Id")
        }
        if headers["X-User-Agent"]?.isBlank ?? true {
            headers.updateValue(YJSReqDescriptor.userAgent, forKey: "X-User-Agent")
        }
        if headers["User-Agent"]?.isBlank ?? true {
            headers.updateValue(YJSReqDescriptor.userAgent, forKey: "User-Agent")
        }
        if headers["x-app-name"]?.isBlank ?? true {
            headers.updateValue(UIApplication.yjs_appName(), forKey: "x-app-name")
        }
        if isEncrypt {
            headers.updateValue("x", forKey: "x-third-token-special")
        }
        customHeader = headers
    }
}

extension YJSReqDescriptor {
    
    public static var userAgent: String {
        //格式：YouShaQi/4.12.0 (iPhone; iOS 12.2; Scale/3.0)
        var bundleName = UIApplication.yjs_bundleName()
        #if TARGET_FTZS
        bundleName = "FTXSRead"
        #endif
        let bundleVersion = UIApplication.yjs_versionShortCode()
        let userAgent = "\(bundleName)/\(bundleVersion) (\(UIDevice.current.model); iOS \(UIDevice.current.systemVersion); Scale/\(UIScreen.main.scale))"
        return userAgent;
    }
    
    public func setPort(_ port: Int) -> YJSReqDescriptor {
        self.hostModel.port = port
        return self
    }
    
    public func setHeader(_ value: String, forKey key: String) -> YJSReqDescriptor {
        customHeader[key] = value
        return self
    }
    
    public func setTimeout(_ timeout: Double) -> YJSReqDescriptor {
        self.timeout = timeout
        return self
    }
    
    public func setIsEncrypt(_ isEncrypt: Bool) -> YJSReqDescriptor {
        self.isEncrypt = isEncrypt
        return self
    }
    
    public func setParameterEncoding(_ encoding: ParameterEncoding) -> YJSReqDescriptor {
        self.parameterEncoding = encoding
        return self
    }
    
    //开始发起请求
    @discardableResult public func responseJSON(completionHandler: @escaping responseCompletionHandler) -> DataRequest? {
        return YJSSessionManager.responseJSON(self, completionHandler: completionHandler)
    }
}
