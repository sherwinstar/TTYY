//
//  TYUserInfoHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/7.
//

import UIKit
import Cache
import BaseModule

class TYUserInfoHelper: NSObject {
    static let shared = TYUserInfoHelper()
    private var userInfo: TYUserInfoModel?
    private let kSaveUserInfoKey = "kSaveUserInfoKey"
    
    private lazy var modelCache : Storage<TYUserInfoModel> = {
        let diskConfig = DiskConfig(name: "com.ttyy.userinfo")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let modelCache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: TYUserInfoModel.self))
        return modelCache
    }()
    
    /// 存储用户信息
    class func saveUserInfo(_ model: TYUserInfoModel?) {
        guard let userInfo = model else { return }
        TYUserInfoHelper.shared.userInfo = userInfo
        TYPushInfoHelper.shared.saveUserToken(userInfo.token)
        try? TYUserInfoHelper.shared.modelCache.setObject(userInfo, forKey: TYUserInfoHelper.shared.kSaveUserInfoKey)
    }
    
    /// 移除用户信息
    class func removeUserInfo() {
        TYUserInfoHelper.shared.userInfo = nil
        try? TYUserInfoHelper.shared.modelCache.removeObject(forKey: TYUserInfoHelper.shared.kSaveUserInfoKey)
        TYPushInfoHelper.shared.saveUserToken("")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationLogoutSuccess), object: nil)
        YJSUMeng.uploadCountEvent(kUMAppLogout, label: nil)
    }
    
    /// 获取用户信息模型
    private func getUserInfoModel() -> TYUserInfoModel {
        if let model = userInfo {
            return model
        }
        
        if let model = try? modelCache.entry(forKey: kSaveUserInfoKey).object {
            userInfo = model
            return model
        }
        
        // 未登录会走到这里
        return TYUserInfoModel()
    }
}

extension TYUserInfoHelper {
    
    /// 对外公开的，获取用户信息模型的方法，如果没有登录，返回nil
    class func openGetUserInfoModel() -> TYUserInfoModel? {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        if model.token.isBlank {
            return nil
        }
        return model
    }
    
    /// 获取token
    class func getUserToken() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.token
    }
    
    /// 获取用户ID
    class func getUserId() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.userId
    }
    
    /// 获取用户昵称
    class func getUserName() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.nickname
    }
    
    /// 是否登录
    class func userIsLogedIn() -> Bool {
        let token = getUserToken()
        if token.isBlank {
            return false
        } else {
            return true
        }
    }
    
    /// 获取用户的邀请码
    class func getUserInviteCode() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.promoterId
    }
    
    /// 获取用户绑定的邀请码
    class func getUserBindInviteCode() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.fpromoterId
    }
    
    /// 获取用户是否绑定邀请码
    class func getUserIsBindInviteCode() -> Bool {
        let code = getUserBindInviteCode()
        if code.isBlank {
            return false
        }
        return true
    }
    
    /// 是否绑定支付宝
    class func getUserIsBindAlipay() -> Bool {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.isBindingAliPay
    }
    
    class func getUserIsBindTaobao() -> Bool {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.isBindingTaobao
    }
    
    class func getTaobaoAccessToken() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.taobaoAccessToken
    }
    
    class func saveTaobaoAccessToken(_ taobaoAccessToken: String) {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        model.taobaoAccessToken = taobaoAccessToken
    }
    
    /// 获取支付宝账户
    class func getUserAlipayAccount() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.aliPayAccountUserName
    }
    
    /// 获取用户身份证姓名
    class func getUserIdCardName() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.idCardName
    }
    
    /// 获取用户身份证号
    class func getUserIdCardNum() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.idCardNum
    }
    
    /// 获取用户头像
    class func getUserHeadImgUrl() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        return model.headImgurl
    }
    
    /// 获取用户类型
    class func getUserTypeString() -> String {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        if model.userType == 1 {
            return " 普通用户 "
        } else if model.userType == 2 {
            return " 合伙人 "
        }
        return ""
    }
    
    /// 获取用户类型，如果出错，返回-1
    class func getUserType() -> Int {
        let model = TYUserInfoHelper.shared.getUserInfoModel()
        if model.userType == 1 || model.userType == 2 {
            return model.userType
        }
        return -1
    }
}
