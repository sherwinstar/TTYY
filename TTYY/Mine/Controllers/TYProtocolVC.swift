//
//  TYProtocolVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/6.
//

import UIKit
import YJSWebModule
import BaseModule

enum ProtocolType {
    case closeAccount // 注销账号
    case contactUs  // 联系客服
    case userAgreement // 用户协议
    case privacyPolicy // 隐私政策
    case thirdSDK // 第三方SDK
}

class TYProtocolVC: TYBaseVC {
    private var type: ProtocolType = .closeAccount
    
    init(type: ProtocolType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubView()
    }
}

private extension TYProtocolVC {
    func createSubView() {
        let webVC = YJSWebStoreVC()
        webVC.originUrl = getUrl()
        webVC.webVC.needEncode = false
        if type == .closeAccount || type == .contactUs {
            webVC.setupHiddenNav()
            webVC.webVC.topMargin = Screen_NavItemY
        }
        addChild(webVC)
        view.addSubview(webVC.view)
        webVC.webVC.webView?.scrollView.bounces = false
        webVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func getUrl() -> String {
        var url = ""
        switch type {
        case .closeAccount:
            url = TYOnlineUrlHelper.getCloseAccountUrl()
        case .contactUs:
            url = TYOnlineUrlHelper.getContactUSURL()
        case .privacyPolicy:
            url = TYOnlineUrlHelper.getPrivacyPolicyURL()
        case .thirdSDK:
            url = TYOnlineUrlHelper.getThirdSDKURL()
        case .userAgreement:
            url = TYOnlineUrlHelper.getUserAgreementURL()
        }
        return url
    }
}
