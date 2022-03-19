//
//  TYOnlineUrlHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/5.
//

import UIKit

// 是否处于测试环境
private let isTesting: Bool = false

class TYOnlineUrlHelper: NSObject {
    
    /// 获取首页的URL
    class func getHomeUrl() -> String {
        return getURL(path: "/ttyy/home")
    }
    
    /// 获取我的页面URL
    class func getMineUrl() -> String {
        return getURL(path: "/ttyy/mine")
    }
    
    /// 获取优选URL
    class func getShopUrl() -> String {
        return getURL(path: "/ttyy/optimization")
    }
    
    /// 获取合伙人URL
    class func getPartner() -> String {
        return getURL(path: "/ttyy/partner")
    }
    
    /// 注销账号
    class func getCloseAccountUrl() -> String {
        return getURL(path: "/ttyy/accountcancel")
    }
    
    /// 联系客服
    class func getContactUSURL() -> String {
        return getURL(path: "/ttyy/service")
    }
    
    /// 用户协议
    class func getUserAgreementURL() -> String {
        return getURL(path: "/agreement/user-agreement-tiantianyouyu.html")
    }
    
    /// 隐私协议
    class func getPrivacyPolicyURL() -> String {
        return getURL(path: "/agreement/user-privacy-tiantianyouyu.html")
    }
    
    /// 第三方SDK
    class func getThirdSDKURL() -> String {
        return getURL(path: "/agreement/partner-tiantianyouyu.html")
    }
    
    /// 搜索商品页面
    class func getSearchProductURL() -> String {
        let path = "/ttyy/search?version=" + UIApplication.yjs_versionShortCode()
        return getURL(path: path)
    }
    
    /// 获取提现页面
    class func getWithdrawURL() -> String {
        return getURL(path: "/ttyy/withdraw")
    }
    
    /// 兑换贝壳
    class func getShellExchangeURL() -> String {
        return getURL(path: "/ttyy/shellexchange")
    }
    
    /// 订单列表
    class func getOrderListURL() -> String {
        return getURL(path: "/ttyy/orderlist")
    }
    
    /// 收益明细
    class func getTransactionRecordsURL() -> String {
        return getURL(path: "/ttyy/transactionrecords")
    }
    
    /// 有余收藏
    class func getCollectionURL() -> String {
        return getURL(path: "/ttyy/collection")
    }
    
    /// 获取提现规则
    class func getWithdrawRuleURL() -> String {
        return getURL(path: "/ttyy/withdrawrules")
    }
    
    /// 获取提现常见问题
    class func getWithdrawQAURL() -> String {
        return getURL(path: "/ttyy/withdrawqa")
    }
    
    /// 获取提现成功地址
    class func getWithdrawstatussuccessURL() -> String {
        return getURL(path: "/ttyy/withdrawstatussuccess?")
    }
    
    /// 获取完整教程地址
    class func getCourseURL() -> String {
        return getURL(path: "/ttyy/courses")
    }
    
    /// 获取新人免费地址
    class func getNewUserFreeURL() -> String {
        let path = "/ttyy/freelist?version=" + UIApplication.yjs_versionShortCode()
        return getURL(path: path)
    }
    
    /// 获取优选页面的轮播下面的模块的URL
    class func getModuleURL(type: Int) -> String {
        let path = "/ttyy/productlist?recomType=\(type)&version=" + UIApplication.yjs_versionShortCode()
        return getURL(path: path)
    }
    
    /// 获取商品详情页地址
    /// - Parameter product: 商品Model
    class func getProductDetailURL(product: TYShopProductModel) -> String {
        return getURL(path: "/ttyy/productdetail?id=" + product.goodsId + "&type=" + product.sType)
    }
    
    class func getURL(path: String) -> String {
        var url = isTesting ? "http://th5.zhuishushenqi.com" : "https://ttyy.zhuishushenqi.com"
        url = url + path
        return url
    }
    
    /// 获取apinew的完整地址
    class func getApiNewURL(path: String) -> String {
        var url = isTesting ? "http://testapinew.zhuishushenqi.com" : "https://apinew.zhuishushenqi.com"
        url = url + path
        return url
    }
}
