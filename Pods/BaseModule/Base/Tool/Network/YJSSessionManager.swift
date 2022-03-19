//
//  YJSSessionManager.swift
//  YouShaQi
//
//  Created by Beginner on 2019/7/4.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

public enum ReachbilityStatus {
    case notReachable
    case unknown
    case wifi
    case cellular
}

public class YJSSessionManager: NSObject {
    
    @objc public static let share = YJSSessionManager()
    private var defaultSession: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = YJSReqDescriptor.defaultTimeOut
        return Alamofire.Session(configuration: config)
    }()
    
    @objc public func startService() {
        //域名轮询
        YJSReqServiceManager.share.registerService(service: YJSReqPollHostServiceProtocol.self, implClass: YJSReqPollHostService.self)
        YJSReqServiceManager.share.createService(service: YJSReqPollHostServiceProtocol.self)
        
        //网络监听
        YJSReqServiceManager.share.registerService(service: YJSReqReachbilityServiceProtocol.self, implClass: YJSReqReachbilityService.self)
        if let reachbilityService = YJSReqServiceManager.share.createService(service: YJSReqReachbilityServiceProtocol.self) as? YJSReqReachbilityServiceProtocol {
            reachbilityService.startService()
        }
        
        //HttpDNS
        YJSReqServiceManager.share.registerService(service: YJSReqDnsServiceProtocol.self, implClass: YJSReqDnsService.self)
        if let dnsService = YJSReqServiceManager.share.createService(service: YJSReqDnsServiceProtocol.self) as? YJSReqDnsServiceProtocol {
            dnsService.startService()
        }
        
        //测试环境配置
        YJSReqServiceManager.share.registerService(service: YJSReqTestConfigServiceProtocol.self, implClass: YJSReqTestConfigService.self)
        if let service = YJSReqServiceManager.share.createService(service: YJSReqTestConfigServiceProtocol.self) as? YJSReqTestConfigServiceProtocol {
            
        }
    }
    
    /// 更新获取章节内容域名轮询列表
    /// - Parameters:
    ///   - hosts: 域名列表
    @objc public func updateChapterPollHostList(_ hosts: [String]?) {
        if let pollHostService = YJSReqServiceManager.share.createService(service: YJSReqPollHostServiceProtocol.self) as? YJSReqPollHostServiceProtocol {
            pollHostService.update(hosts, forHostType: .chapter2)
        }
    }
    
    //创建请求
    private class func createDataRequest(_ reqDesc: YJSReqDescriptor) -> DataRequest? {
        reqDesc.timeout = (reqDesc.timeout == -1 ? YJSReqDescriptor.defaultTimeOut : reqDesc.timeout)
        if reqDesc.timeout != share.defaultSession.sessionConfiguration.timeoutIntervalForRequest {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = reqDesc.timeout
            share.defaultSession = Alamofire.Session(configuration: config)
        }
        
        if (reqDesc.formData != nil) {
            return createFormDataRequest(reqDesc)
        } else {
            return createNormalDataRequest(reqDesc)
        }
    }
    //普通网络请求
    private class func createNormalDataRequest(_ reqDesc: YJSReqDescriptor) -> DataRequest? {
        let encodingType: ParameterEncoding
        if let customType = reqDesc.parameterEncoding {
            encodingType = customType
        } else {
            encodingType = URLEncoding.default
        }
        let dataRequest = share.defaultSession.request(reqDesc.composeUrl(),
                                                       method: reqDesc.method,
                                                       parameters: reqDesc.params,
                                                       encoding: encodingType,
                                                       headers: HTTPHeaders(reqDesc.customHeader))
        return dataRequest
    }
    
    private class func createFormDataRequest(_ reqDesc: YJSReqDescriptor) -> DataRequest? {
        //上传文件
        guard let formData = reqDesc.formData else {
            return nil
        }
        let dataRequest = share.defaultSession.upload(multipartFormData: formData,
                                                      to: reqDesc.composeUrl(),
                                                      method: reqDesc.method,
                                                      headers: HTTPHeaders(reqDesc.customHeader))
        return dataRequest
    }
    
    //完成回调
    private class func handleResponse(dataRequest: DataRequest, responseObj: [String: Any]?, error: Error?) {
        //如果请求失败，则轮询到下一个备用域名
        if error?.asAFError?.isSessionTaskError ?? false {
            guard let pollHostService = YJSReqServiceManager.share.createService(service: YJSReqPollHostServiceProtocol.self) as? YJSReqPollHostServiceProtocol else {
                return
            }
            pollHostService.pollNext(forType: dataRequest.hostType)
        }
    }
}

//MARK: - 对外方法
extension YJSSessionManager {
    
    public class func createRequest(_ hostType: YJSRequestHostType, method: HTTPMethod, path: String, params: [String : Any], formData: MultipartFormData? = nil) -> YJSReqDescriptor {
        let reqDesc = YJSReqDescriptor(hostType, method: method, path: path, params: params, formData: formData)
        return reqDesc
    }
    
    public class func responseJSON(_ reqDesc: YJSReqDescriptor, completionHandler:  @escaping responseCompletionHandler) -> DataRequest? {
        guard let dataRequest = createDataRequest(reqDesc) else {
            return nil
        }
        dataRequest.hostType = reqDesc.hostType
        dataRequest.responseJSON { (response) in
            let resultDic = response.value as? Dictionary<String, Any>
            completionHandler(response.error == nil, resultDic ?? [:], response.error, dataRequest)
            
            handleResponse(dataRequest: dataRequest,
                           responseObj: resultDic,
                           error: response.error)
        }
        return dataRequest
    }
}
