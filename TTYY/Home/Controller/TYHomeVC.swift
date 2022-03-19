//
//  TYHomeVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/5.
//

import UIKit
import YJSWebModule
import BaseModule

class TYHomeVC: TYBaseVC {
    private var homeWebVC = YJSWebStoreVC()
    private let urlStr = TYOnlineUrlHelper.getHomeUrl()
    
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
        homeWebVC.webVC.webView?.scrollView.bounces = false
    }
    
    override func runPageActionJS() {
        let js = "pageActive()"
        homeWebVC.webVC.runScript(js)
    }
}

private extension TYHomeVC {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: Notification.Name(rawValue: TYNotificationLogoutSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(noti:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func loginStateChange() {
        var loginInfo: String = "{}"
        if let userInfoModel = TYUserInfoHelper.openGetUserInfoModel() {
            loginInfo = userInfoModel.kj.JSONString()
        }
        let js = String(format: "updateUserInfo(%@)", loginInfo)
        homeWebVC.webVC.runScript(js)
    }
    
    
    func setupWebView() {
        homeWebVC.defaultBack = false
        homeWebVC.setupHiddenNav()
        homeWebVC.originUrl = urlStr
        homeWebVC.webVC.needEncode = false
        homeWebVC.webVC.loadWebPage(urlStr: urlStr)
        addChild(homeWebVC)
        view.addSubview(homeWebVC.view)
        homeWebVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
    }
    
    /// 键盘
    @objc func keyboardDidChangeFrame(noti: Notification) {
        guard let userInfo = noti.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyY = frame.origin.y
        var keyboardH = Int(frame.size.height)
        if keyY == Screen_Height {
            keyboardH = 0
            homeWebVC.webVC.webView?.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        let js = "onKeyborad(\(keyboardH))"
        homeWebVC.webVC.runScript(js)
    }
}
