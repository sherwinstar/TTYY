//
//  TYShopService.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/15.
//

import Foundation
import BaseModule
import Alamofire

struct TYShopService {
    
    /// 获取优选页面超级爆品
    static func requestExaRecommend(completeHandler:@escaping (Bool, [TYShopProductModel]?) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/ExaRecommend", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
                let models = data.kj.modelArray(TYShopProductModel.self)
                completeHandler(true, models)
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 获取系统推荐商品
    /// - Parameters:
    ///   - type: 1 京东 2 淘宝 3 拼多多
    ///   - recomType: 1 智能推荐 2 9.9包邮 3 好券商品 ，4 高佣精选
    ///   - pageIndex: 页码，每页10条 受接口限制
    static func requestSystemRecommend(type: Int, recomType: Int, pageIndex: Int, searchId: String, completeHandler:@escaping (Bool, [TYShopProductModel]?) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        params["type"] = type
        params["recomType"] = recomType
        params["platform"] = "ios"
        if type == 2 {
            let utdid = UTDevice.utdid() ?? ""
            if !utdid.isBlank {
                params["deviceId"] = UIDevice.yjs_idfaString()
            }
        } else {
            params["deviceId"] = UIDevice.yjs_idfaString()
        }
        params["pageIndex"] = pageIndex
        if !searchId.isBlank {
            params["searchId"] = searchId
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/SystemRecommend", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess {
                if let data = result["data"] as? [[String: Any]], data.count > 0 {
                    let models = data.kj.modelArray(TYShopProductModel.self)
                    completeHandler(true, models)
                } else {
                    completeHandler(true, nil)
                }
            } else {
                completeHandler(false, nil)
            }
        }
    }
    
    /// 获取京东商品文案
    /// - Parameter goodsId: 商品ID
    static func requestJDTkl(goodsId: String, completeHandler:@escaping (String) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        if !goodsId.isBlank {
            params["goodsId"] = goodsId
        }
        
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/JdTkl", params: params).responseJSON { isSuccess, result, error, _ in
            handleGoodsTkl(isSuccess: isSuccess, result: result, completeHandler: completeHandler)
        }
    }
    
    /// 获取拼多多商品文案
    /// - Parameters:
    ///   - goodsId: 商品Id
    static func requestPDDTkl(goodsId: String, completeHandler:@escaping (String) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        if !goodsId.isBlank {
            params["goodsId"] = goodsId
        }
        
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/pddTkl", params: params).responseJSON { isSuccess, result, error, _ in
            handleGoodsTkl(isSuccess: isSuccess, result: result, completeHandler: completeHandler)
        }
    }
    
    private static func handleGoodsTkl(isSuccess: Bool, result: [String: Any], completeHandler:@escaping (String) -> Void) {
        if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
            let info = data[0]
            if let tkl = info["tkl"] as? String, !tkl.isBlank {
                UIPasteboard.general.string = tkl
                completeHandler("已复制到粘贴板")
            }
        } else {
            if let msg = result["msg"] as? String, !msg.isBlank {
                completeHandler(msg)
            }
        }
    }
    
    /// 请求京粉商品筛选
    /// - Parameters:
    ///   - key: 配置的key
    ///   - pageIndex: 页码
    ///   - sortName: 排序字段
    ///   - sort: 升序还是降序
    static func requestJingfenSearch(key: Int, pageIndex: Int, sortName: String, sort: String, completeHandler:@escaping (Bool, [TYShopProductModel]?) -> Void) {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        params["key"] = key
        params["pageIndex"] = pageIndex
        if !sortName.isBlank {
            params["sortName"] = sortName
        }
        if !sort.isBlank {
            params["sort"] = sort
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/JingfenSearch", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess {
                if let data = result["data"] as? [[String: Any]], data.count > 0 {
                    let models = data.kj.modelArray(TYShopProductModel.self)
                    completeHandler(true, models)
                } else {
                    completeHandler(true, nil)
                }
            } else {
                completeHandler(false, nil)
            }
        }
    }
}
