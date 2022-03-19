//
//  TYChannelHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/29.
//

import Foundation
import Alamofire
import KakaJSON
import Cache
import BaseModule
import WebKit

class TYChannelHelper {
    private let kAlreadyRequest = "kAlreadyRequest"
    private let kChannelInfo = "kChannelInfo"
    private let kAlreadyJumpList = "kAlreadyJumpList"
    private var requestChannelHander: (() -> Void)!
    lazy var modelCache : Storage<TYChannelModel> = {
        let diskConfig = DiskConfig(name: "com.ttyy.channel")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let modelCache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: TYChannelModel.self))
        return modelCache
    }()
    
    static let shared = TYChannelHelper()
    
    private var userAgent = ""
    private var webView = WKWebView()
    /// 保存激活时间，当返回的数据不需要保存的时候使用
    private var activeTime = ""
    
    func requestChannelInfo(compeltion: @escaping () -> Void) {
        let boolCache = modelCache.transformCodable(ofType: Bool.self)
        //如果暂时没有网络权限，需要等待用户同意获取网络权限
        if !YJSReachbilityListener.isReachable() {
            NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: kNotiNetworkStatusChanged, object: nil)
            return
        }
        if userAgent.isBlank {
            TYChannelHelper.requestUserAgent {
                self.networkStatusChanged()
            }
            return
        }
        requestChannelHander = { [weak self] in
            try? boolCache.setObject(true, forKey: self?.kAlreadyRequest ?? "")
            NotificationCenter.default.post(name: NSNotification.Name(TYNotificationGetChannelInfoSuccess), object: nil)
            compeltion()
        }
        
        let urlStr = "http://data.1391.com:60005/behavior/clicking/attribution/channel";
        var params = [String: String]()
        params["product_line"] = UIApplication.yjs_productLine()
        params["platform"] = "1";
        params["idfa"] = YJIdfaHelper.uniquelIdfa()
        
        var headers = [String: String]()
        headers["Content-Type"] = "application/json;charset=UTF-8"
        headers["x-token"] = "9afb2dg61f7a71718e906d6698"
        headers["Web-User-Agent"] = userAgent
        
        let manager = Session.default
        manager.session.configuration.timeoutIntervalForRequest = 3
        let dataRequest = manager.request(urlStr,
                                          method: .post,
                                          parameters: params,
                                          encoding: JSONEncoding.default,
                                          headers: HTTPHeaders(headers),
                                          interceptor: nil)
        dataRequest.responseJSON { (response) in
            guard let dic = response.value as? Dictionary<String, Any> else {
                self.requestChannelHander()
                return
            }
            guard let resultDic = dic["result"] as? Dictionary<String, Any> else {
                self.requestChannelHander()
                return
            }
            
            let model = resultDic.kj.model(TYChannelModel.self)
            guard model.attributionCode == 2 else {
                self.activeTime = model.activeTime
                self.requestChannelHander()
                return
            }
            model.bcId = (resultDic["bookId"] as? String ?? "") + "_" + (resultDic["channelId"] as? String ?? "")
            
            do {
                if let oldModel = self.channelInfo(), self.alreadyRequest() {
                    if model.channelId == "-1" && oldModel.channelId != "-1" {
                        model.channelId = oldModel.channelId
                    }
                    if model.channelName == "-1" && oldModel.channelName != "-1" {
                        model.channelName = oldModel.channelName
                    }
                    if model.uaChannelId == "-1" && !oldModel.uaChannelId.isBlank && oldModel.channelName != "-1" {
                        model.uaChannelId = oldModel.uaChannelId
                    }
                    if model.uaChannelName == "-1" && !oldModel.uaChannelName.isBlank && oldModel.uaChannelName != "-1" {
                        model.uaChannelName = oldModel.uaChannelName
                    }
                    try self.modelCache.setObject(model, forKey: self.kChannelInfo)
                } else {
                    try self.modelCache.setObject(model, forKey: self.kChannelInfo)
                }
            } catch {
                print("获取失败！")
            }

            self.requestChannelHander()
        }
    }
    
    @objc func networkStatusChanged() {
        NotificationCenter.default.removeObserver(self)
        requestChannelInfo {
            TYAppDelegateHelper.uploadUserBaseBehavior()
        }
    }
    
    func channelInfo() -> TYChannelModel? {
        do {
            let model = try self.modelCache.entry(forKey: kChannelInfo)
            return model.object
        } catch {
            return nil
        }
    }
    
    func alreadyRequest() -> Bool {
        let boolCache = modelCache.transformCodable(ofType: Bool.self)
        if let alreadyRequest = try? boolCache.entry(forKey: kAlreadyRequest), alreadyRequest.object {
            return true
        }
        return false
    }
}

extension TYChannelHelper {
 
    static func yjs_channel() -> String {
        guard let channelModel = TYChannelHelper.shared.channelInfo() else {
            return "Appttyy"
        }
        if channelModel.channelName == "-1" {
            return "Appttyy"
        }
        return channelModel.channelName
    }
    
    static func yjs_channelID() -> String {
        guard let channelModel = TYChannelHelper.shared.channelInfo() else {
            return "80020211"
        }
        if channelModel.channelId == "-1" {
            return "80020211"
        }
        return channelModel.channelId
    }
    
    static func requestUserAgent(compeltion: @escaping () -> Void) {
        if Thread.isMainThread {
            private_requestUserAgent(compeltion: compeltion)
        } else {
            doInMain {
                private_requestUserAgent(compeltion: compeltion)
            }
        }
    }
    
    private static func private_requestUserAgent(compeltion: @escaping () -> Void) {
        if !TYChannelHelper.shared.userAgent.isBlank {
            compeltion()
            return
        }
        TYChannelHelper.shared.webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
            if error != nil || result == nil {
                TYChannelHelper.shared.userAgent = ""
            } else if let userAgent = result as? String, !userAgent.isBlank {
                TYChannelHelper.shared.userAgent = userAgent
            }
            compeltion()
        }
    }
    
    /// 获取内存中的UA
    @objc static func getUserAgent() -> String {
        return TYChannelHelper.shared.userAgent
    }
}
