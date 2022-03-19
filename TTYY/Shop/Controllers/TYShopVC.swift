//
//  TYShopVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import YJSWebModule
import BaseModule

class TYShopVC: TYBaseVC {

    private var shopWebVC = YJSWebStoreVC()
    private let urlStr = TYOnlineUrlHelper.getShopUrl()
        
    convenience init(preLoad: Bool) {
        self.init()
        setupWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shopWebVC.webVC.webView?.scrollView.bounces = false
    }
    
    override func runPageActionJS() {
        let js = "pageActive()"
        shopWebVC.webVC.runScript(js)
    }
}

private extension TYShopVC {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: Notification.Name(rawValue: TYNotificationLogoutSuccess), object: nil)
    }
    
    @objc func loginStateChange() {
        var loginInfo: String = "{}"
        if let userInfoModel = TYUserInfoHelper.openGetUserInfoModel() {
            loginInfo = userInfoModel.kj.JSONString()
        }
        let js = String(format: "updateUserInfo(%@)", loginInfo)
        shopWebVC.webVC.runScript(js)
    }
    
    func setupWebView() {
        shopWebVC.defaultBack = false
        shopWebVC.setupHiddenNav()
        shopWebVC.originUrl = urlStr
        shopWebVC.webVC.needEncode = false
        shopWebVC.webVC.loadWebPage(urlStr: urlStr)
        addChild(shopWebVC)
        view.addSubview(shopWebVC.view)
        shopWebVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
    }
}
