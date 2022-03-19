//
//  TYMineService.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//

import UIKit
import BaseModule
import Alamofire

class TYMineService: NSObject {
    /// 获取用户资金账户信息
    class func getUserRebateInfo(completeHandler:@escaping (Bool, TYRebateInfoModel?) -> Void) {
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            completeHandler(false, nil)
            return
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/rebateInfo", params: ["token": token]).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
                let model = data.first?.kj.model(TYRebateInfoModel.self)
                completeHandler(true, model)
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 订单列表，固定请求第一页，返利状态：全部
    class func getMineOrderList(completeHandler:@escaping (Bool, [TYOrderInfoModel]?) -> Void) {
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            completeHandler(false, nil)
            return
        }
        var params = [String: Any]()
        params["token"] = token
        params["page"] = 1
        params["rebateStatus"] = 0
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Order/Orderlist", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
                let model = data.kj.modelArray(TYOrderInfoModel.self)
                completeHandler(true, model)
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 提现
    class func withdraw(money: Double, completeHandler:@escaping (Bool, String) -> Void) {
        let token = TYUserInfoHelper.getUserToken()
        if token.isBlank {
            completeHandler(false, "请重新登录后提现")
            return
        }
        var params = [String: Any]()
        params["token"] = token
        params["money"] = money
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/cashAliPay", params: params).responseJSON { isSuccess, dict, error, _ in
            if let ok = dict["ok"] as? Bool, ok, isSuccess {
                completeHandler(true, "提现成功")
            } else {
                var msg = "提现失败"
                if let msgStr = dict["msg"] as? String, !msgStr.isBlank {
                    msg = msgStr
                }
                completeHandler(false, msg)
            }
        }
    }
}
