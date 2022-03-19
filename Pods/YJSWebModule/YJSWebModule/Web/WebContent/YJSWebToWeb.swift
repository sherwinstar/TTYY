//
//  YJSWebToWeb.swift
//  YouShaQi
//
//  Created by Admin on 2020/9/20.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import YJSWebModule
import BaseModule
import YJShareSDK
import MJExtension

final class WebToWeb: YJSWebToModuleProtocol {
    // 通用的
    var callback: WebCallBack?
    var context: YJSWebContext?
    var webItem: YJSWebItem?
    
    weak var webVC: YJSWebContentVC?
    
    @objc public init(webVC: YJSWebContentVC) {
        self.webVC = webVC
    }
    
    @objc public static var moduleIdentifier: String {
        "web"
    }
    @objc public func canHandleWebItem(webItem: YJSWebItem) -> Bool {
        let handled = ["copyBoard", "saveImage", "showToast", "setBounces", "setNavigationBar", "backEvent", "setTopBarColor", "setOptionButton", "pop", "openTaobaoDetail", "onBackButtonClick", "jumpNotificationSetting"].contains(webItem.funcName)
        return handled || supportJump(webItem)
    }
    
    func supportJump(_ webItem: YJSWebItem) -> Bool {
        guard webItem.funcName == "jump" else {
            return false
        }
        
        let supports: [YJSWebItem.JumpType] = [.safari]
        return webItem.jump.map { supports.contains($0) } ?? false
    }
    
    @objc public func handle(navItem: YJSWebNavBtnInnerType, webStore: YJSWebStoreVC) {
        switch navItem {
        case .refresh:
            webVC?.reload()
        case .share, .help:
            webVC?.rightBtnItem.doIfSome { context?.fromVC?.handleWebItem($0) }
        default:
            break
        }
    }
    
    @objc public func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack) {
        guard let webVC = context.fromVC else {
            return
        }
        self.webItem = webItem
        self.context = context
        self.callback = callback
        
        switch webItem.funcName {
        case "copyBoard":
            copyToCopyBoard(webItem: webItem, from: webVC)
        case "saveImage":
            longPressToSaveImage(webItem.paramDic)
        case "showToast":
            showToast(webItem: webItem)
        case "setBounces":
            let bounces = webItem.paramDic?.getNumValue("enabled").flatMap { $0.intValue == 0 ? false : true }
            webVC.webView?.scrollView.bounces = bounces ?? false
        case "setNavigationBar":
            setNavigationBarItems()
        case "backEvent":
            webVC.backEventItem = webItem
        case "setTopBarColor":
            (webItem.paramDic as? WebStrJson).doIfSome { (p) in
                context.delegate?.webView?(webVC, didSetNavBarStyle: p)
            }
        case "setOptionButton":
            context.delegate?.webView?(webVC, setEventVCOptionButton: webItem)
        case "pop":
            context.delegate?.webView?(webVC, h5CallViewPop: webItem.jsStr())
        case "openTaobaoDetail":
            UIApplication.openTaobaoDetail(urlStr: webItem.jsCallbackParamStr)
        case "onBackButtonClick":
            webVC.backButtonEventItem = webItem
        case "jumpNotificationSetting":
            UIApplication.jumpToSystemPushConfig { (isEnable) in
                let param = isEnable ? "true" : "false"
                webItem.jsStr(param).doIfSome {
                    callback($0)
                }
            }
            break
        default:
            break
        }
    }
    
    func setNavigationBarItems() {
        guard let webItem = webItem, let origins = webItem.paramDic?["setNavigationItems"] as? [WebJson] else {
            return
        }
        let items = origins.map { dic -> YJSWebItem in
            var params = dic
            params["jumpType"] = "webview"
            return YJSWebItem(funcName: "", query: nil, param: params)
        }
        context?.fromVC?.navRightItems = items
    }
    
    func copyToCopyBoard(webItem: YJSWebItem, from vc: UIViewController) {
        guard let copied = webItem.paramDic?["copyStr"] else {
            return
        }
        let copy: String
        if let str = copied as? String {
            copy = str
        } else if let num = copied as? NSNumber {
            copy = num.stringValue
        } else {
            return
        }
        UIPasteboard.general.string = copy
        // 如果复制的是红包码，需要发送一个通知，让外界记录下复制的红包码
        if copy.contains("yqhy_") {
            webItem.jsStr().doIfSome {
                callback?($0)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RedpacketCodeCopyNotification"), object: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "已复制到剪贴板".yjs_translateStr(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的".yjs_translateStr(), style: .default, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    func longPressToSaveImage(_ body: WebJson?) {
        guard let imgValue = body?.getStrValue("imageValue") else {
            return
        }
        var isJumpToWeChat = false
        if let wechat = body?.getNumValue("isJumpToWeChat") {
            isJumpToWeChat = wechat.boolValue
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "保存图片".yjs_translateStr(), style: .default, handler: { (_) in
            let isBase64 = (body?["isBase64"] as? NSNumber)?.boolValue ?? false
            let img = isBase64 ?
                Data(base64Encoded: imgValue, options: .ignoreUnknownCharacters).flatMap {
                    UIImage(data: $0)
                } :
                URL(string: imgValue).flatMap {
                    try? Data(contentsOf: $0)
                }.flatMap {
                    UIImage(data: $0)
                }
            guard let image = img, let parentVC = self.context?.fromVC else {
                return
            }
            YJSPhotoUtils.saveImgToAlbum(in: parentVC, img: image) { (isSucceed) in
                guard isSucceed else { return }
                if isJumpToWeChat {
                    if WXApi.isWXAppInstalled() {
                        YJSToast.show("保存成功，正在打开微信")
                    } else {
                        YJSToast.show("保存成功，请安装微信后扫码添加")
                    }
                    doAfterInMain(seconds: 1) {
                        WXApi.openWXApp()
                    }
                } else {
                    YJSToast.show("保存成功")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消".yjs_translateStr(), style: .cancel, handler: nil))
        guard let vc = context?.fromVC, let source = vc.view else {
            return
        }
        alert.popoverPresentationController?.sourceView = source
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: source.height - 200, width: source.width, height: source.height)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showToast(webItem: YJSWebItem) {
        guard let msg = webItem.paramDic?.getStrValue("msg") else {
            return
        }
        // 这种方式不是很合理，但是没有办法
        if msg.contains("您是追书的老朋友了") {
            // 在福利社页面弹出来，不是福利社页面直接返回
            if let vc = UIApplication.getCurrentVC(), NSStringFromClass(vc.classForCoder) != "YouShaQi.FTZSWelfareVC" {
                return
            }
        }
        // 默认1.5秒
        var duration: CGFloat = 1.5
        if let webDuration = webItem.paramDic?.getNumValue("duration")?.floatValue, webDuration > 0 {
            duration = CGFloat(webDuration / 1000.0)
        }
        YJSToast.show(msg, delay: CGFloat(duration))
    }
}

extension UIApplication {
    fileprivate static func openTaobaoDetail(urlStr: String?) {
        guard let dic = urlStr?.mj_JSONObject() as? [String : Any],
            let originUrl = dic["url"] as? String,
            !originUrl.isEmpty else {
            return
        }
        let taobaoUrl = originUrl.range(of: "://")
            .map ({ (range) in
                originUrl[range.lowerBound...]
            })
            .flatMap { (urlExceptScheme) in
                ("taobao" + urlExceptScheme).yjs_queryEncodedURLString()
            }
            .flatMap { (url) in
                URL(string: url)
            }
        if let url = taobaoUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            if let url = originUrl.yjs_queryEncodedURLString().flatMap({ URL(string: $0) }) {
                UIApplication.shared.open(url)
            }
        }
    }
}
