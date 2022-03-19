//
//  TYGameVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import Foundation
import UIKit
import BaseModule

class TYGameVC: TYBaseVC {
    private var webVC: TYGameWebVC?
    
    convenience init(preLoad: Bool) {
        self.init()
        setupSubviews()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

private extension TYGameVC {
    func setupSubviews() {
        let webVC = TYGameWebVC(isPush: false)
        self.webVC = webVC
        addChild(webVC)
        view.addSubview(webVC.view)
        webVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
            make.top.equalToSuperview().offset(Screen_NavItemY)
        }
        webVC.loadWebPage(url: getURL())
    }
    
    func getURL() -> String {
        var urlStr = "https://m.playmy.cn/View/Wall_AdList.aspx?"
        var paramsStr = "t=1&cid=\(kWowanCid)"
        let userId = TYUserInfoHelper.getUserId()
        if !userId.isBlank {
            paramsStr = paramsStr + "&cuid=" + userId
        }
        let idfa = UIDevice.yjs_idfaString()
        if !idfa.isBlank {
            paramsStr = paramsStr + "&deviceid=" + idfa
        }
        let timeInterval = Int64(Date().timeIntervalSince1970)
        paramsStr = paramsStr + "&unixt=\(timeInterval)"
        
        let md5Str = (paramsStr + kWowanKey).yj_MD5String() ?? ""
        if !md5Str.isBlank {
            paramsStr = paramsStr + "&keycode=" + md5Str
        }
        urlStr = urlStr + paramsStr
        return urlStr
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
    }
    
    @objc func loginStateChange() {
        webVC?.loadWebPage(url: getURL())
    }
}


