//
//  TYProductInfoModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/20.
//

import UIKit
import KakaJSON

class TYProductInfoModel: Convertible {
    /// 商品所在平台 pdd、taobao、jd
    var sType = ""
    /// 平台ICON
    var sTypeIcon = ""
    /// 商家标题
    var merchantTitle = ""
    /// 购买人数
    var payUser = 0
    /// 图片
    var goodsImgUrl = ""
    /// 商品标题
    var goodsTitle = ""
    /// 商品ID
    var goodsId = ""
    /// 券
    var coupons: CGFloat = 0
    /// 节省金额 /返利金额
    var saveMoney: CGFloat = 0
    /// 到手价
    var price: CGFloat = 0
    /// 原价
    var originalprice: CGFloat = 0
    /// 链接
    var jumpUrl = ""
    /// 搜索ID
    var searchId = ""

    
    required init() {}
}
