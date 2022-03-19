//
//  TYWebToShop.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/14.
//

import UIKit
import YJSWebModule
import BaseModule
import DuoduoJinbaoSDK

class TYWebToShop: NSObject {
    // 通用的
    var callback: WebCallBack?
    var context: YJSWebContext?
    var webItem: YJSWebItem?
    weak var webVC: YJSWebContentVC?
    
    required init(webVC: YJSWebContentVC) {
        self.webVC = webVC
        super.init()
    }
}

extension TYWebToShop: YJSWebToModuleProtocol {
    static var moduleIdentifier: String {
        "shop"
    }
    
    func canHandleWebItem(webItem: YJSWebItem) -> Bool {
        let handled = ["getTaoBaoAccessToken"].contains(webItem.funcName)
        return handled || supportJump(webItem)
    }
    
    func supportJump(_ webItem: YJSWebItem) -> Bool {
        guard webItem.funcName == "jump" else {
            return false
        }
        let supports: [YJSWebItem.JumpType] = [.product_detail, .optimization, .game_center]
        return webItem.jump.map { supports.contains($0) } ?? false
    }
    
    func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack) {
        self.webItem = webItem
        self.context = context
        self.callback = callback
        
        switch webItem.funcName {
        case "jump":
            jump()
        case "getTaoBaoAccessToken":
            getTaobaoAccessToken()
        default:
            break
        }
    }
}

private extension TYWebToShop {
    func jump() {
        guard let jump = webItem?.jump, let webVC = context?.fromVC else {
            return
        }
        switch jump {
        case .product_detail:
            jumpProductDetail(webVC)
        case .optimization:
            jumpShop()
        case .game_center:
            jumpGameVC()
        default:
            break
        }
    }
    
    func jumpShop() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 1])
    }
    
    func jumpGameVC() {
        if TYHuYanHelper.getCheckEnableState() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 3])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 1])
        }
    }
    
    func jumpProductDetail(_ webVC: YJSWebContentVC) {
        guard let type = webItem?.productTypeStr else {
            webVC.parent?.showToast(msg: "发生错误，请联系客服")
            return
        }
        if type == "jd" {
            if let url = webItem?.productUrlStr?.removingPercentEncoding, !url.isBlank {
                KeplerApiManager.sharedKPService().openKeplerPage(withURL: url, userInfo: nil) {
                } failedCallback: { code, message in
                    if code == 422 {
                        // 未安装京东，直接打开h5
                        let vc = TYShopWebVC(url: url)
                        webVC.parent?.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                    if !message.isBlank {
                        webVC.parent?.showToast(msg: message)
                    }
                }
            }
        } else if type == "pdd" {
            if let url = webItem?.productUrlStr?.removingPercentEncoding, !url.isBlank {
                DuoduoJinbaoSDK.openPDD(withURL: url) { error in
                    if let err = error {
                        let code = (err as NSError).code
                        if code == 2 {
                            let vc = TYShopWebVC(url: url)
                            webVC.parent?.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                    }
                    if var errorMsg = error?.localizedDescription, !errorMsg.isBlank {
                        if errorMsg == "Invalid url" {
                            errorMsg = "未安装拼多多客户端"
                        }
                        webVC.parent?.showToast(msg: errorMsg)
                    }
                }
            }
        } else if type == "taobao" {
            if let url = webItem?.productUrlStr?.removingPercentEncoding, !url.isBlank {
                openTaoBao(url: url)
            }
        }
    }
    
    func openTaoBao(url: String) {
        guard let nav = webVC?.parent?.navigationController else { return }
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
//        showParam.isNeedCustomNativeFailMode = true
//        showParam.nativeFailMode = .jumpDownloadPage
//        showParam.degradeUrl = url
        if let third = TYThirdLoadingType(rawValue:"taobao") {
            TYThirdLoadingView.show(type: third)
        }
        let _ = AlibcTradeSDK.sharedInstance().tradeService().open(byUrl: url, identity: "trade", webView: nil, parentController: nav, showParams: showParam, taoKeParams: nil, trackParam: nil) { result in
        } tradeProcessFailedCallback: { error in
        }
        TYThirdLoadingView.remveView()
    }
    
    /// 获取淘宝授权
    func getTaobaoAccessToken() {
        guard let vc = UIApplication.getCurrentVC() else { return }
        let taobaoAccessToken = TYUserInfoHelper.getTaobaoAccessToken()
        var accessToken = ""
        if !taobaoAccessToken.isBlank {
            accessToken = "'" + taobaoAccessToken + "'"
            self.webItem?.jsStr(accessToken).doIfSome({
                self.callback?($0)
            })
            return
        }
        
        if !ALBBCompatibleSession.sharedInstance().isLogin() {
            ALBBSDK.sharedInstance().setH5Only(false)
            ALBBSDK.sharedInstance().auth(vc) { [weak self] in
                if let topAccessToken = ALBBCompatibleSession.sharedInstance().getUser().topAccessToken {
                    accessToken = topAccessToken
                    if !accessToken.isBlank {
                        TYUserInfoHelper.saveTaobaoAccessToken(accessToken)
                        accessToken = "'" + accessToken + "'"
                        self?.webItem?.jsStr(accessToken).doIfSome({
                            self?.callback?($0)
                        })
                    }
                }
            } failureCallback: { _ in
            }
        } else {
            if let topAccessToken = ALBBCompatibleSession.sharedInstance().getUser().topAccessToken {
                accessToken = topAccessToken
            }
            if !accessToken.isBlank {
                TYUserInfoHelper.saveTaobaoAccessToken(accessToken)
                accessToken = "'" + accessToken + "'"
                webItem?.jsStr(accessToken).doIfSome({
                    callback?($0)
                })
            }
        }
    }
}
