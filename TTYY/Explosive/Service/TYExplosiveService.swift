//
//  TYExplosiveService.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/11.
//

import Foundation
import BaseModule
import Alamofire

struct TYExplosiveService {
    /// 获取爆品页面好物推荐、品牌爆品
    static func requestRecommendType(completeHandler:@escaping (Bool, [TYShopRecommendType]?) -> Void) {
        var params = [String: Any]()
//        let token = TYUserInfoHelper.getUserToken()
//        if !token.isBlank {
//            params["token"] = token
//        }
        params["group"] = "jrzt"
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/ExaRecommendType", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
                let models = data.kj.modelArray(TYShopRecommendType.self)
                completeHandler(true, models)
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 获取爆品页面好物推荐、品牌爆品
    static func requestRecommend(goodsType:Int, completeHandler:@escaping (Bool, [TYShopProductModel]?) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        params["goodsType"] = goodsType
//        params["pageIndex"] = pageIndex
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/ExaRecommend", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]] {
                let models = data.kj.modelArray(TYShopProductModel.self)
                completeHandler(true, models)
            } else {
                completeHandler(false, nil)
            }
        }
    }
}
