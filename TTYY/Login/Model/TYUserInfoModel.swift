//
//  TYUserInfoModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/7.
//

import KakaJSON

class TYUserInfoModel: Convertible, Decodable, Encodable {
    /// 用户token
    var token: String = ""
    /// 用户ID
    var userId: String = ""
    /// 用户性别 none 未知 male 男生 female 女生
    var sex: String = ""
    /// 昵称
    var nickname: String = ""
    /// 头像
    var headImgurl: String = ""
    /// 注册时间
    var regTime: String = ""
    /// 最后登录时间
    var lastLoginTime: String = ""
    /// 是否绑定手机号
    var isBindingMobile: Bool = false
    /// 绑定的手机号
    var bindingMobile: String = ""
    /// 是否绑定身份证
    var isBindingIDCard: Bool = false
    /// 身份证号码
    var idCardNum: String = ""
    /// 姓名
    var idCardName: String = ""
    /// 是否绑定支付宝
    var isBindingAliPay: Bool = false
    /// 支付宝账户
    var aliPayAccountUserName: String = ""
    /// pdd是否授权
    var isBindingPdd: Bool = false
    /// Taobao是否授权
    var isBindingTaobao: Bool = false
    /// 用户类型 1 普通用户 2. 合伙人
    var userType: Int = 0
    /// 邀请码
    var promoterId: String = ""
    /// 推广数量
    var promotionQuantity: Int = 0
    /// 绑定的邀请码
    var fpromoterId: String = ""
    
    var taobaoAccessToken: String = ""
    
    required init() {}
}
