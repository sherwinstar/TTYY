//
//  TYHomeService.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/3.
//

import Foundation
import BaseModule
import Alamofire

struct TYHomeService {
    
    /// 请求基础配置
    /// - Parameters:
    ///   - type: 基础参数配置， 用户首页人数 = FrontTitleConfig，三期用户首页人数 = FrontTitleConfig_v2， 搜索热词 =HotSearch 分类 =items
    static func requestBaseConfig(type: String, completeHandler:@escaping (Bool, [TYBaseConfigModel]?) -> Void) {
        if type.isBlank {
            completeHandler(false, nil)
            return
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Config/BaseConfig", params: ["type": type]).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, isSuccess, let data = result["data"] as? [[String: Any]], data.count > 0 {
                let models = data.kj.modelArray(TYBaseConfigModel.self)
                completeHandler(true, models)
            } else {
                completeHandler(false, nil)
            }
        }
    }
}
