//
//  YJSReqHostModel.swift
//  YouShaQi
//
//  Created by Beginner on 2020/5/29.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import Cache

public enum YJSRequestHostType: String, CaseIterable {
    case outServer = ""
    //支持域名轮询
    case api = "api"
    case b = "b"
    case bookApi = "bookApi"
    case chapter2 = "chapter2"
    //不支持域名轮询
    case auth = "auth"
    case community = "community"
    case ctoc = "ctoc"
    case statics = "statics"
    case h5 = "h5"
    case goldCoin = "goldCoin"
    case goldCoinNew = "goldCoinNew"
    case newApi = "newApi"
    case pay = "pay"
    case purchase = "purchase"
    case activityApi = "activityApi"
    case activityNew = "activityNew"
        
    case lyApi = "lyApi"
    case d1391 = "d1391"
    case data1391 = "data1391"
    case mhjk1391 = "mhjk1391"
    case marketnew = "marketnew"
    case convert = "convert"
}

public class YJSReqHostModel {
    ///域名类型
    var type: YJSRequestHostType
    ///是否支持HTTPS
    var isSupportHttps = false
    ///是否支持域名轮询
    var isSupportPolls = false
    ///是否支持HttpDns
    var isSupportDns = false
    ///域名端口号
    var port = 80
    ///域名轮询列表
    var pollHosts = [String]()
    ///默认域名配置
    let dicHost: [YJSRequestHostType: String] = [.api: "api.zhuishushenqi.com",
                                                 .b: "b.zhuishushenqi.com",
                                                 .bookApi: "bookApi01.zhuishushenqi.com",
                                                 .chapter2: "chapter2.zhuishushenqi.com",
                                                 .auth: "auth.zhuishushenqi.com",
                                                 .community: "community.zhuishushenqi.com",
                                                 .ctoc: "ctoc.zhuishushenqi.com",
                                                 .statics: "statics.zhuishushenqi.com",
                                                 .h5: "h5.zhuishushenqi.com",
                                                 .goldCoin: "goldcoin.zhuishushenqi.com",
                                                 .goldCoinNew: "goldcoinnew.zhuishushenqi.com",
                                                 .newApi: "apinew.zhuishushenqi.com",
                                                 .pay: "pay.zhuishushenqi.com",
                                                 .activityApi: "activityapi.zhuishushenqi.com",
                                                 .activityNew: "activitynew.zhuishushenqi.com",
                                                 .lyApi: "lyapi.1391.com",
                                                 .d1391: "d.1391.com",
                                                 .data1391: "data.1391.com",
                                                 .mhjk1391: "mhjk.1391.com",
                                                 .marketnew: "marketnew.zhuishushenqi.com",
                                                 .convert: "convert.zhuishushenqi.com"]
    //保存当前域名
    lazy var hostConfigCache : Storage<String> = {
        let diskConfig = DiskConfig(name: "com.yjn.host.config.string")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: String.self))
        return cache
    }()
    
    init(_ hostType: YJSRequestHostType) {
        self.type = hostType
        
        switch hostType {
        case .api, .b, .bookApi, .chapter2:
            isSupportPolls = true
            isSupportDns = true
        default:
            isSupportPolls = false
            isSupportDns = false
        }
    }
    
    ///当前域名
    func curHostString() -> String {
        let testService = YJSReqServiceManager.share.createService(service: YJSReqTestConfigServiceProtocol.self) as? YJSReqTestConfigServiceProtocol
        if let service = testService, service.testHostEnable(type),  !service.testHost(type).isBlank {
            return service.testHost(type)
        }
        var host = dicHost[type] ?? ""
        if isSupportPolls {
            do {
                host = (try hostConfigCache.entry(forKey: type.rawValue)).object
            } catch {
                try! hostConfigCache.setObject(host, forKey: type.rawValue)
            }
        }
        if port == 80 {
            return host
        } else {
            return "\(host):\(port)"
        }
    }
    
    func curIp() -> String {        
        if isSupportDns == false {
            return curHostString()
        }
        guard let service = YJSReqServiceManager.share.createService(service: YJSReqDnsServiceProtocol.self) as? YJSReqDnsServiceProtocol else {
            return curHostString()
        }
        
        return service.getHostIP(curHostString())
    }
}
