//
//  TYWebToUser.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/5.
//

import UIKit
import BaseModule
import YJSWebModule
import YJShareSDK


class TYWebToUser: NSObject {
    // 通用的
    var callback: WebCallBack?
    var context: YJSWebContext?
    var webItem: YJSWebItem?
    
    weak var webVC: YJSWebContentVC?
    
    required init(webVC: YJSWebContentVC) {
        self.webVC = webVC
        super.init()
    }
    
    func viewStateChanged(webStore: YJSWebStoreVC, changed: ViewStateChange) {
        switch changed {
        case .didLoad:
            setupNav(webStore)
        default:
            break
        }
    }
    
    private func setupNav(_ webstore: YJSWebStoreVC) {
        
    }
}

extension TYWebToUser: YJSWebToModuleProtocol {
    public static var moduleIdentifier: String {
        "user"
    }
    
    func canHandleWebItem(webItem: YJSWebItem) -> Bool {
        let handled = ["getUserInfo", "getStatusBarHeight", "sharespread", "getDeviceInfo", "openWeiXin","openMiniApp"].contains(webItem.funcName)
        return handled || supportJump(webItem)
    }
    
    func supportJump(_ webItem: YJSWebItem) -> Bool {
        guard webItem.funcName == "jump" else {
            return false
        }
        let supports: [YJSWebItem.JumpType] = [.setting, .login, .alipay_withdraw_setting, .join_partner, .bind_invite_code]
        return webItem.jump.map { supports.contains($0) } ?? false
    }
    
    func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack) {
        guard let _ = context.fromVC else {
            return
        }
        self.callback = callback
        self.context = context
        self.webItem = webItem
        
        switch webItem.funcName {
        case "getUserInfo":
            tellUserInfoToH5()
        case "getStatusBarHeight":
            tellBarHeightToH5()
        case "sharespread":
            share()
        case "getDeviceInfo":
            getDeviceInfo()
        case "openWeiXin":
            openWeChat()
        case "openMiniApp":
            openMiniApp()
        case "jump":
            jump()
        default:
            break
        }
    }
}

private extension TYWebToUser {
    func tellUserInfoToH5() {
        guard let _ = webItem?.jsCallback else {
            return
        }
        var loginInfo: [String: Any] = [:]
        if let userInfoModel = TYUserInfoHelper.openGetUserInfoModel() {
            loginInfo = userInfoModel.kj.JSONObject()
        }
        let data = try? JSONSerialization.data(withJSONObject: loginInfo, options: .fragmentsAllowed)
        let info = data.flatMap {
            String.init(data: $0, encoding: .utf8)
        }
        info.flatMap { webItem?.jsStr($0) }.doIfSome({ (js) in
            callback?(js)
        })
    }
    func tellBarHeightToH5() {
        guard let _ = webItem?.jsCallback else {
            return
        }
        let heightStr = "\(Screen_NavItemY)"
        webItem?.jsStr(heightStr).doIfSome({
            callback?($0)
        })
    }
    
    func share() {
        guard let group = webItem?.paramDic?.getStrValue("group") else {
            return
        }
        if group == "img" {
            if let img = webItem?.paramDic?.getStrValue("src") {
                TYShareManager.shared.shareImage(url: img, webItem: webItem, callback: callback)
            }
        } else if group == "inviteDownload" {
            var url = "/shopping/Config/shareImg/" + TYUserInfoHelper.getUserInviteCode()
            url = TYOnlineUrlHelper.getApiNewURL(path: url)
            TYShareManager.shared.shareImage(url: url, webItem: webItem, callback: callback)
        }
    }
    
    func getDeviceInfo() {
        guard let _ = webItem?.jsCallback else {
            return
        }
        let utdid = UTDevice.utdid() ?? ""
        let paramStr = [
            "IDFA" : UIDevice.yjs_idfaString(),
            "UTDID" : utdid
        ].jsonString()
        paramStr.flatMap { webItem?.jsStr($0) }.doIfSome({ (js) in
            callback?(js)
        })
    }
    
    /// 打开微信
    func openWeChat() {
        if WXApi.isWXAppInstalled() {
            WXApi.openWXApp()
        } else {
            showToast(msg: "您未安装微信客户端")
        }
    }
    
    func openMiniApp() {
        let userName = webItem?.paramDic?.getStrValue("id")
        let type = webItem?.paramDic?.getStrValue("type")
        let path = webItem?.paramDic?.getStrValue("value")
        let deeplink = webItem?.paramDic?.getStrValue("deeplink") ?? ""
        if let url = URL(string: deeplink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if WXApi.isWXAppInstalled() {
            if !type.isBlank, let third = TYThirdLoadingType(rawValue: type ?? "") {
                TYThirdLoadingView.show(type: third)
            }
            let launchMiniProgramReq = WXLaunchMiniProgramReq.object()
            launchMiniProgramReq.miniProgramType = .release
            launchMiniProgramReq.userName = userName ?? ""
            launchMiniProgramReq.path = path
            WXApi.send(launchMiniProgramReq) { success in
                TYThirdLoadingView.remveView()
            }
        } else {
            showToast(msg: "您未安装微信客户端")
        }
    }
}

private extension TYWebToUser {
    func jump() {
        guard let jump = webItem?.jump, let webVC = context?.fromVC else {
            return
        }
        switch jump {
        case .setting:
            goSettingVC(webVC)
        case .login:
            goLogin(webVC)
        case .alipay_withdraw_setting:
            goSettingWithdraw(webVC)
        case .join_partner:
            goPartner()
        case .bind_invite_code:
            goBindInviteCode(webVC)
        default:
            break
        }
    }
    
    /// 设置
    func goSettingVC(_ webVC: YJSWebContentVC) {
        let settingVC = TYSettingVC()
        webVC.parent?.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    /// 登录
    func goLogin(_ webVC: YJSWebContentVC) {
        let loginVC = TYLoginVC()
        loginVC.delegate = self
        webVC.parent?.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    /// 提现设置页面
    func goSettingWithdraw(_ webVC: YJSWebContentVC) {
        let alipayVC = TYAliPaySettingVC()
        webVC.parent?.navigationController?.pushViewController(alipayVC, animated: true)
    }
    
    /// 前往合伙人页面
    func goPartner() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 2])
    }
    
    /// 前往绑定邀请码界面
    func goBindInviteCode(_ webVC: YJSWebContentVC) {
        let bindVC = TYBindInviteCodeVC()
        webVC.parent?.navigationController?.pushViewController(bindVC, animated: true)
    }
}

extension TYWebToUser: TYLoginVCProtocol {
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool) {
        if state == false {
            return
        }
        // 登录成功后，需要执行回调
        tellUserInfoToH5()
    }
    
    func loginVCClose(_ loginVC: TYLoginVC) {}
}

extension TYWebToUser: YJSWebUserInfoProtocol {
    static func isLogin() -> Bool {
        return TYUserInfoHelper.userIsLogedIn()
    }
    
    static func userId() -> String? {
        return TYUserInfoHelper.getUserId()
    }
    
    static func userToken() -> String? {
        return TYUserInfoHelper.getUserToken()
    }
    
    static func userUniqueId() -> String? {
        return nil
    }
    
    static func userGender() -> String? {
        return nil
    }
    
    static func youngMode() -> Bool {
        return false
    }
    
    static func userPreferrce() -> [AnyHashable : Any]? {
        return nil
    }
    
    static func goLogin(from parentVC: UIViewController) {
        let loginVC = TYLoginVC()
        parentVC.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    static var loginSucceedNotificationName: Notification.Name {
        Notification.Name(rawValue: "NotificationLoginSuccess")
    }
}
