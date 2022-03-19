//
//  TYLogHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/29.
//

import Foundation
import BaseModule
import Alamofire

enum TYUserBehaviorTag: Int {
    case launch = 1
    case register
    case login
}

class TYLogHelper {
    static let shared = TYLogHelper()
    
    func uploadUserBaseBehavior(tag: TYUserBehaviorTag) {
        if !TYChannelHelper.shared.alreadyRequest() {
            // 获取渠道信息成功或者失败之前，不上传埋点
            return
        }
        
        if let logEnabled = TYOnlineParamsHelper.shared.onlineParamsModel?.logSwitch?.logBaseBehaviorEnabled, logEnabled == false {
            return
        }
        
        // 冷启动一天只上传一次
        if tag == .launch {
            if let uploadDate = TYCacheHelper.getCacheString(for: "UserBaseBehaviorLaunchUploadDate"), !uploadDate.isBlank {
                let nowDate = DateFormatUtils.sharedInstance().seventhDateFormatter.string(from: Date.init())
                if uploadDate == nowDate {
                    return
                }
            }
        }
        
        uploadUserBaseBehaviors(params: baseBehaviorParams(tag: tag))
    }
}

private extension TYLogHelper {
    func baseBehaviorParams(tag: TYUserBehaviorTag) -> [String: Any] {
        var params = [String: Any]()
        var operateTypeStr = ""
        switch tag {
        case .launch:
            operateTypeStr = "1"
        case .register:
            operateTypeStr = "2"
        case .login:
            operateTypeStr = "3"
        }
        params["operate_type"] = operateTypeStr
        params["app_market_name"] = TYChannelHelper.yjs_channel()
        params["client_version"] = UIApplication.yjs_versionShortCode()
        params["log_time"] = DateFormatUtils.sharedInstance().secondDateFormatter.string(from:Date.init())
        params["platform"] = 1
        params["device_imei"] = YJIdfaHelper.uniquelIdfa() ?? "-1"
        params["device_mac"] = YJIdfaHelper.macString() ?? "-1"
        params["user_id"] = TYUserInfoHelper.getUserId()
        params["user_name"] = UIDevice.yjs_uniquelIdfa()
        params["activity_code"] = TYChannelHelper.yjs_channelID()
        var platformStr = UIDevice.platformString()
        if platformStr.isBlank {
            platformStr = "-1"
        }
        params["phone_model"] = platformStr
        params["phone_resolution"] = "-1"
        params["os_version"] = UIDevice.yjs_systemVersion()
        
        return params
    }
    
    func behaviorMD5Str(params: [String : [[String : Any]]], randomNum: UInt32, dateStr: String, secret: String) -> String {
        let prefixStr = "app_secret=" + secret + "&biz_content="
        var finalJsonStr = prefixStr
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let jsonStr = String.init(data: jsonData, encoding: .utf8) {
            finalJsonStr.append(jsonStr)
        }
        
        finalJsonStr.append("&product_line=1&rn=\(randomNum)&sign_type=MD5&timestamp=" + dateStr)
        var base64Str = finalJsonStr.yj_md5AndBase64Str() ?? ""
        base64Str = base64Str.replacingOccurrences(of: "+", with: "-")
        base64Str = base64Str.replacingOccurrences(of: "/", with: "_")
        base64Str = base64Str.replacingOccurrences(of: "=", with: "")
        
        return TYUrlUtils.encode(toPercentEscape: base64Str) ?? ""
    }
    
    func uploadUserBaseBehaviors(params: [String: Any]) {
        let userAgent = TYChannelHelper.getUserAgent()
        if userAgent.isBlank {
            TYChannelHelper.requestUserAgent {
                self.uploadUserBaseBehaviors(params: params)
            }
            return
        }
        let logArr = [params]
        let bodyJson = ["dataInfos": logArr]
        let dateStr = DateFormatUtils.sharedInstance().secondDateFormatter.string(from: Date.init())
        let randomNum = arc4random() % 999999
        let md5Str = behaviorMD5Str(params: bodyJson, randomNum: randomNum, dateStr: dateStr, secret: "b5f8fe5k59eb0c6524787b6d1ar91924")
        let urlStr = String(format: "http://d.1391.com:50207/v1.0.0/h/warehouse/log/applog/batch/receive?timestamp=%@&product_line=26&rn=%d&sign_type=MD5&sign=%@", TYUrlUtils.encode(toPercentEscape: dateStr) ?? "", randomNum, md5Str)
        guard let url = URL(string: urlStr) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 25.0
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyJson, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "Web-User-Agent")
        if !YJSReachbilityListener.isReachable() {
            return
        }
        
        var headers = [String: String]()
        headers["Content-Type"] = "application/json;charset=UTF-8"
        headers["x-token"] = "9afb2dg61f7a71718e906d6698"
        headers["Web-User-Agent"] = userAgent
        
        let manager = Session.default
        manager.session.configuration.timeoutIntervalForRequest = 3
        let dataRequest = manager.request(urlStr,
                                          method: .post,
                                          parameters: bodyJson,
                                          encoding: JSONEncoding.default,
                                          headers: HTTPHeaders(headers),
                                          interceptor: nil)
        
        dataRequest.responseJSON { (response) in
            let resultDic = response.value as? [String: Any]
            if let code = resultDic?["code"] as? String, !code.isBlank, code == "10000", response.error == nil {
                self.saveRequestSuccess()
            }
            
        }
    }
    
    func saveRequestSuccess() {
        let nowDate = DateFormatUtils.sharedInstance().seventhDateFormatter.string(from: Date.init())
        TYCacheHelper.cacheString(value: nowDate, for: "UserBaseBehaviorLaunchUploadDate")
    }
}
