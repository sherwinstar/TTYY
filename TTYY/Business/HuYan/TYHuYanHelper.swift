//
//  TYHuYanHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/19.
//

import UIKit
import BaseModule

class TYHuYanHelper: NSObject {
    static var publisherCallBackRequestCount: Int = 0
    static var kCheckEnableState = "kCheckEnableStateThird"
    
    class func startPublisherRequest() {
        // 如果连续请求了5次都失败了，则不再请求，直到下次再启动
        if publisherCallBackRequestCount >= 5 {
            return
        }
        let version = UIApplication.yjs_versionShortCode()
        let publisherId = UIApplication.yjs_publisherID()
        let secret = (version + publisherId).yj_MD5String() ?? ""
        var params = [String: Any]()
        params["appName"] = UIApplication.yjs_appName()
        params["channelName"] = "AppStore"
        params["version"] = version
        params["publisherID"] = publisherId
        params["secret"] = secret
        YJSSessionManager.createRequest(.api, method: .get, path: "/push/publisherInfo", params: params).responseJSON { isSuccess, result, error, _ in
            if isSuccess {
                if let retSecret = result["secret"] as? String, let valid = result["valid"] as? Bool, let localSecret = (publisherId + version).yj_MD5String(), !retSecret.isBlank, retSecret == localSecret, valid {
                    TYCacheHelper.cacheBool(value: true, for: kCheckEnableState)
                } else {
                    TYCacheHelper.cacheBool(value: false, for: kCheckEnableState)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationCheckEnableFinish), object: nil)
            } else {
                publisherCallBackRequestCount += 1
                doAfterInMain(seconds: 15) {
                    startPublisherRequest()
                }
            }
        }
    }
    
    class func getCheckEnableState() -> Bool {
        return TYCacheHelper.getCacheBool(for: kCheckEnableState) ?? false
    }
}
