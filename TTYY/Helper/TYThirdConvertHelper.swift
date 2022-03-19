//
//  TYThirdConvertHelper.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/8.
//
import UIKit
import BaseModule
import YJSWebModule
import DuoduoJinbaoSDK

class TYThirdConvertHelper: NSObject {
    
    static let shared = TYThirdConvertHelper()
    private var platformType: TYPlatformType = .eleme
    private var goodsId = ""
    
    class func goThird(_ platformType: TYPlatformType) {
        if !TYUserInfoHelper.userIsLogedIn() {
            let loginVC = TYLoginVC()
            let helper = TYThirdConvertHelper.shared
            loginVC.delegate = helper
            helper.platformType = platformType
            UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
            return
        }
        switch platformType {
        case .eleme:
            goH5(url: TYOnlineUrlHelper.getURL(path: "/ttyy/eleme"))
        case .jd:
            goJD()
        case .pdd:
            goPdd()
        case .taobao:
            goTaoBao(topAccessToken: nil)
        case .meituan:
            goH5(url: TYOnlineUrlHelper.getURL(path: "/ttyy/meituan"))
        }
        
    }
}

private extension TYThirdConvertHelper {
    
    class func goJD() {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        params["url"] = "https://h5.m.jd.com/babelDiy/Zeus/WjFGeHcYzp1LjdQYrB5sGAaUMma/index.html?pageId=hot"
        requestActivityUrl(url: "/shopping/Goods/JdUrlConvert", type: .jd, params: params) { isSuccess, url in
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
    
    class func goPdd() {
        var params = [String: Any]()
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        params["resType"] = 39996
        requestActivityUrl(url: "/shopping/Goods/PddResourceConvert",type: .pdd, params: params) { isSuccess, url in
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
    
    class func goTaoBao(topAccessToken: String?) {
        if TYUserInfoHelper.getUserIsBindTaobao() {
            openTaobao(nil)
        } else if let accessToken = topAccessToken, !accessToken.isBlank {
            openTaobao(accessToken)
        } else {
            getTaobaoAccessToken()
        }
    }
    
    private class func openTaobao(_ topAccessToken: String?) {
        var params = [String: Any]()
        if let accessToken = topAccessToken, !accessToken.isBlank {
            params["topAccessToken"] = accessToken
        }
        let token = TYUserInfoHelper.getUserToken()
        params["token"] = token
        params["platform"] = 2
        params["iType"] = 3
        requestActivityUrl(url: "/shopping/Goods/TaobaoActivityConvert", type: .taobao, params: params) { isSuccess, url in
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
    
    /// 获取淘宝授权
    class func getTaobaoAccessToken() {
        guard let vc = UIApplication.getCurrentVC() else { return }
        let taobaoAccessToken = TYUserInfoHelper.getTaobaoAccessToken()
        if !taobaoAccessToken.isBlank {
            goTaoBao(topAccessToken: taobaoAccessToken)
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
                        goTaoBao(topAccessToken: accessToken)
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
                goTaoBao(topAccessToken: accessToken)
            }
        }
    }
    
    class func requestActivityUrl(url: String, type: TYThirdLoadingType ,params:[String: Any], completeHandler:@escaping (Bool, String?) -> Void) {
        TYThirdLoadingView.show(type: .pdd);
        YJSSessionManager.createRequest(.newApi, method: .post, path: url, params: params).responseJSON { isSuccess, result, error, _ in
            TYThirdLoadingView.remveView()
            if let ok = result["ok"] as? Bool, ok, let data = result["data"] as? [String: Any] {
                var longUrl = data["longUrl"] as? String
                if longUrl.isBlank {
                    longUrl = data["mobileUrl"] as? String
                }
                if longUrl.isBlank {
                    longUrl = data["shotUrl"] as? String
                }
                completeHandler(true, longUrl)
            }
        }
    }
    
    class func goH5(url: String) {
        let web = YJSWebStoreVC()
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.originUrl = url
        web.setupHiddenNav()
        web.webVC.loadWebPage(urlStr: url)
        UIApplication.getCurrentVC()?.navigationController?.pushViewController(web, animated: true)
    }
}

extension TYThirdConvertHelper: TYLoginVCProtocol {
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool) {
        if state {
            TYThirdConvertHelper.goThird(TYThirdConvertHelper.shared.platformType)
        }
    }
    
    func loginVCClose(_ loginVC: TYLoginVC) {
        
    }
}

