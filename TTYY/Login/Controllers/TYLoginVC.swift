//
//  TYLoginVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/6.
//

import UIKit
import BaseModule
import YJShareSDK

protocol TYLoginVCProtocol: NSObjectProtocol {
    /// 登录成功
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool)
    /// 登录页面关闭(手动点击返回也调用, 登录成功也调用)
    func loginVCClose(_ loginVC: TYLoginVC)
}

extension TYLoginVCProtocol {
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool){}
    func loginVCClose(_ loginVC: TYLoginVC) {}
}

class TYLoginVC: TYBaseVC {
    
    private var privacyView = TYLoginPrivacyView()
    weak var delegate: TYLoginVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoginView()
    }
    
    override func onLeftClicked(at index: Int) -> Bool {
        loginVCDismiss()
        return true
    }
}

private extension TYLoginVC {
    func createLoginView() {
        setupNavBar()
        
        let logoImg = UIImageView(image: UIImage(named: "about_us_logo"))
        view.addSubview(logoImg)
        logoImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(54) + Screen_NavHeight)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(privacyView)
        privacyView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(49))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-49))
            make.bottom.equalToSuperview().offset(-Screen_SafeBottomHeight - Screen_IPadMultiply(26))
            make.height.equalTo(Screen_IPadMultiply(40))
        }
        
        let huYan = TYHuYanHelper.getCheckEnableState()
        if (huYan && WXApi.isWXAppInstalled()) || !ystem_version_iOS13  {
            let weChatBtn = UIButton()
            weChatBtn.setImage(UIImage(named: "login_wechat_icon"), for: .normal)
            weChatBtn.setImage(UIImage(named: "login_wechat_icon"), for: .highlighted)
            weChatBtn.setTitleColor(.white, for: .normal)
            weChatBtn.setTitle(" 微信一键登录".yjs_translateStr(), for: .normal)
            weChatBtn.contentHorizontalAlignment = .center
            weChatBtn.setBackgroundColor(Color_Hex(0x07C160), for: .normal)
            weChatBtn.setBackgroundColor(Color_Hex(0x07C160), for: .highlighted)
            weChatBtn.titleLabel?.font = Font_Medium_IPadMul(18)
            weChatBtn.layer.cornerRadius = Screen_IPadMultiply(12)
            weChatBtn.layer.masksToBounds = true
            weChatBtn.addTarget(self, action: #selector(weChatLoginAction), for: .touchUpInside)
            view.addSubview(weChatBtn)
            weChatBtn.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
                make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
                make.bottom.equalTo(privacyView.snp.top).offset(Screen_IPadMultiply(-96))
                make.height.equalTo(Screen_IPadMultiply(52))
            }
            
            let tipView = UIView()
            view.addSubview(tipView)
            tipView.isUserInteractionEnabled = false
            let lbBounds = CGRect(x: 0, y: 0, width: Screen_IPadMultiply(78), height: Screen_IPadMultiply(22))
            tipView.bounds = lbBounds
            tipView.roundCorners([.topLeft, .topRight, .bottomRight], radius: Screen_IPadMultiply(11))
            
            let layer = CAGradientLayer.init()
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.colors = [Color_Hex(0xE11521).cgColor, Color_Hex(0xFE3E49).cgColor]
            layer.frame = lbBounds
            tipView.layer.addSublayer(layer)
            tipView.snp.makeConstraints { (make) in
                make.centerY.equalTo(weChatBtn.snp.centerY).offset(Screen_IPadMultiply(-7))
                make.centerX.equalTo(weChatBtn.snp.centerX).offset(Screen_IPadMultiply(108))
                make.height.equalTo(Screen_IPadMultiply(22))
                make.width.equalTo(Screen_IPadMultiply(78))
            }
            
            let tipLb = UILabel()
            tipLb.text = "单单有钱赚".yjs_translateStr()
            tipLb.textAlignment = .center
            tipLb.textColor = .white
            tipLb.font = Font_Medium_IPadMul(12)
            tipView.addSubview(tipLb)
            tipLb.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        if #available (iOS 13, *) {
            let appleBtn = UIButton()
            appleBtn.setImage(UIImage(named: "login_apple_icon"), for: .normal)
            appleBtn.setTitleColor(.black, for: .normal)
            appleBtn.setTitle(" 通过 Apple 登录".yjs_translateStr(), for: .normal)
            appleBtn.contentHorizontalAlignment = .center
            appleBtn.setBackgroundColor(.white, for: .normal)
            appleBtn.setBackgroundColor(.white, for: .highlighted)
            appleBtn.titleLabel?.font = Font_Medium_IPadMul(18)
            appleBtn.layer.cornerRadius = Screen_IPadMultiply(12)
            appleBtn.layer.masksToBounds = true
            appleBtn.layer.borderWidth = 1
            appleBtn.layer.borderColor = UIColor.black.cgColor
            appleBtn.addTarget(self, action: #selector(appleLoginAction), for: .touchUpInside)
            view.addSubview(appleBtn)
            appleBtn.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
                make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
                make.bottom.equalTo(privacyView.snp.top).offset(Screen_IPadMultiply(-156))
                make.height.equalTo(Screen_IPadMultiply(52))
            }
        }
    }
}
// MARK: - 处理事件
private extension TYLoginVC {
    
    @objc func weChatLoginAction() {
        if !privacyView.isSelected {
            showToast(msg: "请勾选同意《天天有余APP用户协议》和《用户隐私政策》后登录".yjs_translateStr(), duration: 2)
            return
        }
        
        if !WXApi.isWXAppInstalled() {
            showToast(msg: "您未安装微信客户端")
            return
        }
        TYLoginService.getWXAuthorization { [weak self] isSuccess, params in
            if let dict = params, isSuccess {
                self?.showProgress()
                TYLoginService.loginWX(params: dict) { isSuccess in
                    self?.handleAfterLogin(isSuccess)
                }
            } else {
                self?.hideProgress(msg: "授权失败！")
            }
        }
    }
    
    @objc func appleLoginAction() {
        if !privacyView.isSelected {
            showToast(msg: "请勾选同意《天天有余APP用户协议》和《用户隐私政策》后登录".yjs_translateStr(), duration: 2)
            return
        }
        let helper = TYAppleLoginHelper.shared
        helper.delegate = self
        helper.handleAppleLoginAuthorization()
    }
    
    /// 登录后的处理
    /// - Parameter state: 是否成功
    func handleAfterLogin(_ state: Bool) {
        if state {
            YJSUMeng.uploadCountEvent(kUMAppUserLogin, label: nil)
            hideProgress(msg: "登录成功".yjs_translateStr())
            if let delegate = delegate {
                delegate.loginVCClose(self)
                if delegate .isKind(of: TYThirdConvertHelper.self) || delegate .isKind(of: TYThirdConvertHelper.self) {
                    navigationController?.popViewController(animated: false)
                } else {
                    navigationController?.popViewController(animated: true)
                }
                delegate.loginVC(self, loginFinished: true)
            } else {
                loginVCDismiss()
            }
            
//            let isBind = TYUserInfoHelper.getUserIsBindInviteCode()
//            let key = "TYBindInviteCodeVCShow_" + TYUserInfoHelper.getUserId()
//            let bindShowed = TYCacheHelper.getCacheBool(for: key) ?? false
//            if !isBind && !bindShowed {
//                let bindVC = TYBindInviteCodeVC()
//                bindVC.isFromLogin = true
//                TYCacheHelper.cacheBool(value: true, for: key)
//                navigationController?.pushViewController(bindVC, animated: true)
//            } else {
//                loginVCDismiss()
//            }
        } else {
            hideProgress(msg: "登录失败".yjs_translateStr())
        }
    }
    
    func loginVCDismiss() {
        delegate?.loginVCClose(self)
        navigationController?.popViewController(animated: true)
    }
}

extension TYLoginVC: TYAppleLoginHelperProtocol {
    func appleLoginAuthrizationSuccess(params: [String : Any]) {
        showProgress()
        TYLoginService.loginApple(params: params) { [weak self] isSuccess in
            self?.handleAfterLogin(isSuccess)
        }
    }
    
    func appleLoginAuthrizationFailed(error: String) {
        showToast(msg: error)
    }
}
