//
//  TYShopProductModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/15.
//

import KakaJSON

struct TYShopProductModel: Convertible {
    /// 商品所在平台 pdd、taobao、jd
    var sType: String = ""
    /// 1 联盟商品 2 非联盟商品
    var goodUnionType: Int = 0
    /// 平台ICON
    var sTypeIcon: String = ""
    /// 商家标题
    var merchantTitle: String = ""
    /// 购买人数
    var payUser: String = ""
    /// 图片
    var goodsImgUrl: String = ""
    /// 商品标题
    var goodsTitle: String = ""
    /// 商品ID
    var goodsId: String = ""
    /// 券
    var coupons: Float = 0
    /// 优惠券截止日期
    var couponsDate: String = ""
    /// 详情页图片
    var imageList: [String]?
    /// 节省金额 /返利金额
    var saveMoney: Float = 0
    /// 到手价
    var price: Float = 0
    /// 原价
    var originalprice: Float = 0
    /// 链接
    var jumpUrl: String = ""
    /// 客户端暂时用不到
    var couplink: String = ""
    /// 搜索ID
    var searchId: String = ""
}
