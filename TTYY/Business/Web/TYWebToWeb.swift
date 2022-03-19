//
//  TYWebToWeb.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/12.
//

import UIKit
import BaseModule
import YJSWebModule
import Photos

class TYWebToWeb: NSObject {
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

extension TYWebToWeb: YJSWebToModuleProtocol {
    static var moduleIdentifier: String {
        return "webToWeb"
    }
    
    func canHandleWebItem(webItem: YJSWebItem) -> Bool {
        let handled = ["syncSearchHistory", "saveImages"].contains(webItem.funcName)
        return handled || supportJump(webItem)
    }
    
    func supportJump(_ webItem: YJSWebItem) -> Bool {
        guard webItem.funcName == "jump" else {
            return false
        }
        let supports: [YJSWebItem.JumpType] = [.webview]
        return webItem.jump.map { supports.contains($0) } ?? false
    }
    
    func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack) {
        guard let webVC = context.fromVC else {
            return
        }
        self.webItem = webItem
        self.context = context
        self.callback = callback
        
        switch webItem.funcName {
        case "jump": 
            jump(webItem, from: webVC)
        case "syncSearchHistory":
            syncSearchHistory(webItem)
        case "saveImages":
            saveImages(webItem)
        default:
            break;
        }
    }
}

extension TYWebToWeb {
    func syncSearchHistory(_ webItem: YJSWebItem) {
        let keys = (webItem.paramDic?["list"] as? String) ?? ""
        if keys.isBlank {
            TYCacheHelper.removeString(for: kSaveSearchKeyWordHistoryKey)
        } else {
            TYCacheHelper.cacheString(value: keys, for: kSaveSearchKeyWordHistoryKey)
        }
    }
    
    func saveImages(_ webItem: YJSWebItem) {
        let urlStr = (webItem.paramDic?["imgs"] as? String) ?? ""
        let images = urlStr.components(separatedBy: ",")
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                if status == .authorized {
                    self?.saveImages(urls: images)
                }
            }
        case .restricted, .denied:
            let msg = "天天有余需要您的授权才能访问相册存储图片哦~"
            YJSAlert.showAlert(in: UIApplication.getCurrentVC() ?? UIViewController(), title: nil, msg: msg, cancelTitle: nil, cancelClosure: { (_) in
                YJSToast.show("您未开启相册权限，可稍后去 设置-隐私-照片 开启")
            }, confirmTitle: "前往设置") { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case .authorized:
            saveImages(urls: images)
        default:
            break
        }
    }
    
    func saveImages(urls: [String]) {
        for e in urls.enumerated() {
            if let imgURL = URL(string: e.element) {
                SDWebImageDownloader.shared().downloadImage(with: imgURL, options: .highPriority) { _, _ in
                    
                } completed: { [weak self] image, data, error, _ in
                    var isEnd = false
                    if e.offset == urls.count - 1 {
                        isEnd = true
                    }
                    self?.saveImage(image: image, isEnd: isEnd)
                }
            }
        }
    }
    func saveImage(image: UIImage?, isEnd: Bool) {
        guard let img = image else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        }) { (success, error) in
            if isEnd && success {
                self.showToast(msg: "保存成功")
            }
        }
    }
    
    // 跳转入口
    func jump(_ webItem: YJSWebItem, from webVC: YJSWebContentVC) {
        guard let jump = webItem.jump else {
            return
        }
        switch jump {
        case .webview:
            jumpToWeb(webItem, from: webVC)
        default:
            break
        }
    }
    
    // 跳转网页
    func jumpToWeb(_ webItem: YJSWebItem, from webVC: YJSWebContentVC) {
        guard let type = webItem.paramDic?.getStrValue("jumpType"), type == "webview" else {
            return
        }
        var url = webItem.link ?? ""
        if let link = webItem.link {
            
            if link.contains("/ttyy/service") {
                let vc = TYContactUsVC()
                if let nav = webVC.navigationController {
                    nav.pushViewController(vc, animated: true)
                }
                return
            } else if link.contains("/ttyy/withdraw") {
                let vc = TYWithdrawVC()
                if let nav = webVC.navigationController {
                    nav.pushViewController(vc, animated: true)
                }
                return
            } else if link.contains("/ttyy/search") {
                let keys = TYCacheHelper.getHistoryKeyWordArray(for: kSaveSearchKeyWordHistoryKey)
                let count = keys?.count ?? 0
                if count == 0 {
                    url = url + "&clearSearchHistory=true"
                }
            }
        }
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        if let nav = webVC.navigationController {
            nav.pushViewController(web, animated: true)
        } else {
            webVC.present(web, animated: true, completion: nil)
        }
    }
}
