//
//  TYCopyProductHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/20.
//

import UIKit
import BaseModule
import YJSWebModule
import DuoduoJinbaoSDK

class TYCopyProductHelper: NSObject {
    
    static let shared = TYCopyProductHelper()
    private var tkl = ""
    private var goodsId = ""
    
    class func requestSearch(tkl: String) {
        var searchType = 0
        if tkl.contains("item.m.jd.com") {
            searchType = 1
        } else if tkl.contains("mobile.yangkeduo.com") {
            searchType = 3
        } else if tkl.contains("m.tb.cn") {
            searchType = 2
        }
        if searchType == 0 {
            return
        }
        var params = [String: Any]()
        params["tkl"] = tkl
        params["SearchType"] = "\(searchType)"
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/Goods/SearchTkl", params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok {
                if let data = result["data"] as? [[String: Any]], let modelDict = data.first {
                    let model = modelDict.kj.model(TYProductInfoModel.self)
                    self.show(productModel: model, tkl: tkl)
                } else {
                    self.show(productModel: nil, tkl: tkl)
                }
            }
        }
    }
}

extension TYCopyProductHelper {
    class func show(productModel: TYProductInfoModel?, tkl: String) {
        if let subV = UIApplication.shared.keyWindow?.viewWithTag(100010) {
            subV.removeFromSuperview()
        }
        let productView = TYCopyProductView()
        productView.createSubview(productModel, tkl: tkl)
        productView.tag = 100010
        UIApplication.shared.keyWindow?.addSubview(productView)
        productView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        productView.btnClickClosure = { (type, goodsId) in
            self.goSearchH5(type, tkl: tkl)
        }
    }
    
    class func goSearchH5(_ type: Int, tkl: String) {
        let web = YJSWebStoreVC()
        var activeSortType = "price"
        if(type != 4) {
            activeSortType = "mult"
        }
        var url = TYOnlineUrlHelper.getSearchProductURL() + "?"
        if let tabbar = UIApplication.getTabbarVC() {
            let count = tabbar.barItems.count
            let index = tabbar.getSelectedIndex()
            switch index {
            case 0:
                url = url + "search_source=首页口令商品"
            case 1:
                url = url + "search_source=优选口令商品"
            case 2:
                url = url + "search_source=爆品口令商品"
            case 3:
                if(count == 5) {
                    url = url + "search_source=游戏口令商品"
                } else {
                    url = url + "search_source=我的口令商品"
                }
            case 4:
                url = url + "search_source=我的口令商品"
            default:
                break
            }
        }

        url = url + "&activeSortType=\(activeSortType)&activeSortValue=0"
        url = url + "&activePlatform=\(type)"
        let set = NSMutableCharacterSet()
        set.formUnion(with: .alphanumerics)
        set.formUnion(with: CharacterSet(charactersIn: "-_.!~*'()"))
        let ret = tkl.addingPercentEncoding(withAllowedCharacters: set as CharacterSet)
        if let third = ret, !third.isBlank {
            web.webVC.appendAfterEncodeStr = "&val=" + third
        }
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.originUrl = url
        web.setupHiddenNav()
        web.webVC.loadWebPage(urlStr: url)
        UIApplication.getCurrentVC()?.navigationController?.pushViewController(web, animated: true)
    }
    
    class func goThird(_ tkl: String, goodsId: String?) {
        guard let productId = goodsId else { return }
        if !TYUserInfoHelper.userIsLogedIn() {
            let loginVC = TYLoginVC()
            let helper = TYCopyProductHelper.shared
            loginVC.delegate = helper
            helper.tkl = tkl
            helper.goodsId = productId
            UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
            return
        }
        if tkl.contains("item.m.jd.com") {
            goJD(productId)
        } else if tkl.contains("mobile.yangkeduo.com") {
            goPdd(productId)
        } else if tkl.contains("m.tb.cn") {
            goTaoBao(productId, topAccessToken: nil)
        }
    }
    
    class func goJD(_ goodsId: String) {
        var params = [String: Any]()
        params["goodsId"] = goodsId
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        requestGoodsUrl(goodsId, url: "/shopping/Goods/JDGoodsUrl", params: params) { isSuccess, url in
            if let mobileUrl = url?.removingPercentEncoding, !mobileUrl.isBlank, isSuccess {
                KeplerApiManager.sharedKPService().openKeplerPage(withURL: mobileUrl, userInfo: nil) {
                } failedCallback: { code, message in
                    if !message.isBlank {
                        UIApplication.getCurrentVC()?.showToast(msg: message)
                    }
                }
            }
        }
    }
    
    class func goPdd(_ goodsId: String) {
        var params = [String: Any]()
        params["goodsId"] = goodsId
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        requestGoodsUrl(goodsId, url: "/shopping/Goods/PddGoodsUrl", params: params) { isSuccess, url in
            if let mobileUrl = url, !mobileUrl.isBlank, isSuccess {
                DuoduoJinbaoSDK.openPDD(withURL: mobileUrl) { error in
                    if var errorMsg = error?.localizedDescription, !errorMsg.isBlank {
                        if errorMsg == "Invalid url" {
                            errorMsg = "未安装拼多多客户端"
                        }
                        UIApplication.getCurrentVC()?.showToast(msg: errorMsg)
                    }
                }
            }
        }
    }
    
    private class func openTaoBao(_ goodsId: String, topAccessToken: String?) {
        var params = [String: Any]()
        if let accessToken = topAccessToken, !accessToken.isBlank {
            params["topAccessToken"] = accessToken
        }
        params["goodsId"] = goodsId
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        params["platform"] = 2
        requestGoodsUrl(goodsId, url: "/shopping/Goods/TaobaoGoodsUrl", params: params) { isSuccess, url in
            if let mobileUrl = url?.removingPercentEncoding, !mobileUrl.isBlank, isSuccess {
                guard let nav = UIApplication.getCurrentVC()?.navigationController else { return }
                let showParam = AlibcTradeShowParams()
                if let taobao = URL(string: "taobao://"), UIApplication.shared.canOpenURL(taobao) {
                    showParam.openType = .native
                    showParam.nativeFailMode = .none
                } else {
                    showParam.openType = .auto
                    showParam.nativeFailMode = .jumpH5
                }
                showParam.isNeedPush = true
                showParam.linkKey = "taobao"

                let _ = AlibcTradeSDK.sharedInstance().tradeService().open(byUrl: mobileUrl, identity: "trade", webView: nil, parentController: nav, showParams: showParam, taoKeParams: nil, trackParam: nil) { result in
                } tradeProcessFailedCallback: { error in
                }
            }
        }
    }
    
    class func goTaoBao(_ goodsId: String, topAccessToken: String?) {
        if TYUserInfoHelper.getUserIsBindTaobao() {
            openTaoBao(goodsId, topAccessToken: nil)
        } else if let accessToken = topAccessToken, !accessToken.isBlank {
            openTaoBao(goodsId, topAccessToken: accessToken)
        } else {
            getTaobaoAccessToken(goodsId)
        }
    }
    
    /// 获取淘宝授权
    class func getTaobaoAccessToken(_ goodsId: String) {
        guard let vc = UIApplication.getCurrentVC() else { return }
        let taobaoAccessToken = TYUserInfoHelper.getTaobaoAccessToken()
        if !taobaoAccessToken.isBlank {
            goTaoBao(goodsId, topAccessToken: taobaoAccessToken)
            return
        }
        var accessToken = ""
        if !ALBBCompatibleSession.sharedInstance().isLogin() {
            ALBBSDK.sharedInstance().setH5Only(false)
            ALBBSDK.sharedInstance().auth(vc) {
                if let topAccessToken = ALBBCompatibleSession.sharedInstance().getUser().topAccessToken {
                    accessToken = topAccessToken
                    if !accessToken.isBlank {
                        TYUserInfoHelper.saveTaobaoAccessToken(accessToken)
                        goTaoBao(goodsId, topAccessToken: accessToken)
                    }
                }
            } failureCallback: { error in
                print(error?.localizedDescription ?? "")
            }
        } else {
            if let topAccessToken = ALBBCompatibleSession.sharedInstance().getUser().topAccessToken {
                accessToken = topAccessToken
            }
            if !accessToken.isBlank {
                TYUserInfoHelper.saveTaobaoAccessToken(accessToken)
                goTaoBao(goodsId, topAccessToken: accessToken)
            }
        }
    }
    
    class func requestGoodsUrl(_ goodsId: String, url: String, params:[String: Any], completeHandler:@escaping (Bool, String?) -> Void) {
        YJSSessionManager.createRequest(.newApi, method: .post, path: url, params: params).responseJSON { isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok, let data = result["data"] as? [String: Any], let mobileUrl = data["mobileUrl"] as? String, !mobileUrl.isBlank {
                completeHandler(true, mobileUrl)
            }
        }
    }
}

extension TYCopyProductHelper: TYLoginVCProtocol {
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool) {
        if state {
            TYCopyProductHelper.goThird(TYCopyProductHelper.shared.tkl, goodsId: TYCopyProductHelper.shared.goodsId)
        }
    }
    
    func loginVCClose(_ loginVC: TYLoginVC) {
        
    }
}
