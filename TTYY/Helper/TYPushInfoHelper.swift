//
//  TYPushInfoHelper.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/10.
//

import UIKit
import BaseModule
import Alamofire

class TYPushInfoHelper: NSObject {
    static let shared = TYPushInfoHelper()
    private var deviceToken: String?
    private var userToken: String?
    private var cid: String?
    private var needBind = true
    
    func saveCid(_ cid: String) -> Void {
        if cid == self.cid && !needBind {
            return
        }
        self.cid = cid
        needBind = true
        bindGeTui()
    }
    
    func saveUserToken(_ userToken: String) -> Void {
        if userToken == self.userToken && !needBind{
            return
        }
        self.userToken = userToken;
        needBind = true
        bindGeTui()
    }
    
    func saveDeviceToken(_ deviceToken: String) -> Void {
        self.deviceToken = deviceToken
    }
    
    /// 绑定个推
    func bindGeTui() {
        if !needBind {
            return
        }
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank || cid == nil || cid!.isBlank {
            return
        }
        let params = ["token": token, "cid": cid!, "platform": 2] as [String : Any]
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/bindGetui", params: params).responseJSON { [weak self] isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess {
                self?.needBind = false
            } else {
                self?.needBind = true
            }
        }
    }
}
