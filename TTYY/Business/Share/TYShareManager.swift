//
//  TYShareManager.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/22.
//

import UIKit
import YJShareSDK
import YJSWebModule
import BaseModule


class TYShareManager: NSObject {
    static let shared = TYShareManager()
    
    private var shareImgUrl: String = ""
    private var callback: WebCallBack?
    private var webItem: YJSWebItem?
    
    func shareImage(url: String, webItem: YJSWebItem?, callback: WebCallBack?) {
        guard let inView = UIApplication.getCurrentVC()?.view else { return }
        shareImgUrl = url
        self.callback = callback
        self.webItem = webItem
        let shareView = TYShareView {
            inView.containingViewController().dismissSemiModalView()
        }
        shareView.shareClosure = { [weak self] (isThird, type) in
            if isThird {
                self?.shareThird(type)
            } else {
                self?.downloadImg()
            }
        }
        inView.containingViewController().presentSemiView(shareView)
    }
    
    func shareImage(url: String) {
        guard let inView = UIApplication.getCurrentVC()?.view else { return }
        shareImgUrl = url
        let shareView = TYShareView {
            inView.containingViewController().dismissSemiModalView()
        }
        shareView.shareClosure = { [weak self] (isThird, type) in
            if isThird {
                self?.shareThird(type)
            } else {
                self?.downloadImg()
            }
        }
        inView.containingViewController().presentSemiView(shareView)
    }
}

private extension TYShareManager {
    func shareThird(_ type: SSDKShareType) {
        let params = NSMutableDictionary()
        params["image"] = shareImgUrl
        params["type"] = 2
        ThirdLoginSDK.share(type, parameters: params) { state, userData, error in
            self.webItem?.jsStr().doIfSome({
                self.callback?($0)
            })
            if type == .ssFriend || type == .ssTimeLine {
                self.showToast(msg: "微信平台分享成功")
                return
            }
            switch state {
            case .success:
                self.showToast(msg: "分享成功")
            case .fail:
                self.showToast(msg: "分享失败")
            case .cancel:
                self.showToast(msg: "分享已取消")
            default:
                break
            }
        }
    }
    
    func downloadImg() {
        guard let url = URL(string: shareImgUrl) else {
            showToast(msg: "图片地址有误，请联系客服")
            return
        }
        showProgress()
        SDWebImageDownloader.shared().downloadImage(with: url, options: .highPriority) { _, _ in
        } completed: { image, _, _, _ in
            doInMain {
                self.hideProgress()
                guard let vc = UIApplication.getCurrentVC(), let img = image else {
                    self.showToast(msg: "图片保存失败")
                    return
                }
                YJSPhotoUtils.saveImgToAlbum(in: vc, img: img) { (isSucceed) in
                    guard isSucceed else { return }
                    YJSToast.show("保存成功")
                }
            }
        }
    }
}
