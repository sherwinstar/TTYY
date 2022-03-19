//
//  TYPartnerVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/5.
//

import UIKit
import YJSWebModule
import BaseModule

class TYPartnerVC: TYBaseVC {

    private var partnerWebVC = YJSWebStoreVC()
    private let urlStr = TYOnlineUrlHelper.getPartner()
        
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
        partnerWebVC.webVC.webView?.scrollView.bounces = false
    }
    
    override func runPageActionJS() {
        let js = "pageActive()"
        partnerWebVC.webVC.runScript(js)
    }
}

private extension TYPartnerVC {
    
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
        partnerWebVC.webVC.runScript(js)
    }
    
    func setupWebView() {
        partnerWebVC.defaultBack = false
        partnerWebVC.setupHiddenNav()
        partnerWebVC.originUrl = urlStr
        partnerWebVC.webVC.needEncode = false
        partnerWebVC.webVC.loadWebPage(urlStr: urlStr)
        addChild(partnerWebVC)
        view.addSubview(partnerWebVC.view)
        partnerWebVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
    }
}
