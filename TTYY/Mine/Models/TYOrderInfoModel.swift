//
//  TYOrderInfoModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//

import KakaJSON

class TYOrderInfoModel: Convertible {
    /// 商品所在平台 pdd、taobao、jd
    var sType: String = ""
    /// 用户ID
    var userId: String = ""
    /// 父级用户ID
    var fuserId: String = ""
    /// 订单状态 1 查看订单 2 交易关闭 3 不显示
    var orderStatus: Int = 0
    /// 返利状态 1 待结算 2 已结算 3 已失效
    var rebateStatus: String = ""
    /// 订单ID
    var orderID: String = ""
    /// 预估返利金额/实际返利金额，根据订单状态匹配
    var rebateMoney: Float = 0
    /// 推广员拿到的金额 如果是普通用户 actualRebateMoney *0.2 ，如果是合伙人 0
    var promoterMoney: Float = 0
    /// 订单金额
    var money: Float = 0
    /// 购买数量
    var quantity: Int = 0
    /// 下单时间
    var dCreateTime: String = ""
    // 订单完成时间
    var dComplateTime: String = ""
    /// 返利时间
    var dRebateTime: String = ""
    /// 商家标题
    var merchantTitle: String = ""
    /// 图片
    var goodsImgUrl: String = ""
    /// 商品标题
    var goodsTitle: String = ""
    /// 订单类型 1 普通订单， 2 新人免单
    var orderPromoteType: Int = 0
    required init() {}
}
