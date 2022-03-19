//
//  TYPrivacyViewController.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/21.
//

import UIKit
import BaseModule
import YJSWebModule

enum PrivacyAlertOrder {
    case first
    case second
    case third
}

let kHasAgreePrivacyProtocolCacheKey = "kHasAgreePrivacyProtocolCacheKey"

class TYPrivacyViewController: UIViewController {
    private var alertOrder: PrivacyAlertOrder = .first
    private var bgView = UIView()
    private var privacyBgView = UIView()
    private var titleLb = UILabel()
    private var contentTextV = UITextView()
    private var agreeBtn = UIButton()
    private var notAgreeBtn = UIButton()
    
    var agreeClosure: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        createPrivacyView()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func enterFirstGuide() {
        createFirstInstallTip()
    }
}

private extension TYPrivacyViewController {
    func createView() {
        view.backgroundColor = .clear
        view.addSubview(bgView)
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    //虚假的引导，为了进入广告查询弹窗
    func createFirstInstallTip() {
        let firstInstall = TYCacheHelper.getCacheBool(for: kAppFirstInstallKey) ?? false
        if firstInstall {
            return
        }
        privacyBgView.removeFromSuperview()
        let firstInstallView = UIView()
        firstInstallView.backgroundColor = .white
        view.addSubview(firstInstallView)
        firstInstallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let imgV = UIImageView(image: UIImage.yjs_webpImage(imageName: "launch_second"))
        firstInstallView.addSubview(imgV)
        imgV.center = view.center
    }
    
    func createPrivacyView() {
        privacyBgView.backgroundColor = .white
        privacyBgView.layer.cornerRadius = Screen_IPadMultiply(8)
        privacyBgView.layer.masksToBounds = true
        view.addSubview(privacyBgView)
        privacyBgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(270))
            make.height.equalTo(Screen_IPadMultiply(361))
        }
        
        titleLb.font = Font_Medium_IPadMul(17)
        titleLb.text = "感谢您使用天天有余！".yjs_translateStr()
        titleLb.textColor = Color_Hex(0x000000)
        titleLb.textAlignment = .center
        privacyBgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-20))
        }
        
        contentTextV.backgroundColor = .white
        privacyBgView.addSubview(contentTextV)
        contentTextV.snp.makeConstraints { make in
            make.top.equalTo(titleLb.snp.bottom).offset(Screen_IPadMultiply(20))
            make.centerX.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(230))
            make.height.equalTo(Screen_IPadMultiply(190))
        }
        contentTextV.attributedText = handleContent()
        contentTextV.linkTextAttributes = [.underlineStyle: 1]
        contentTextV.delegate = self
        contentTextV.isEditable = false
        contentTextV.textContainerInset = .zero
        contentTextV.textContainer.lineFragmentPadding = 0

        privacyBgView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-55))
            make.height.equalTo(Screen_IPadMultiply(40))
            make.width.equalTo(Screen_IPadMultiply(166))
            make.centerX.equalToSuperview()
        }
        agreeBtn.titleLabel?.font = Font_Medium_IPadMul(17)
        agreeBtn.layer.cornerRadius = Screen_IPadMultiply(20)
        agreeBtn.layer.masksToBounds = true
        agreeBtn.setTitle("同意并进入".yjs_translateStr(), for: .normal)
        agreeBtn.setBackgroundColor(Color_Hex(0xEE4745), for: .normal)
        agreeBtn.addTarget(self, action: #selector(clickedBtnEvent(_:)), for: .touchUpInside)
        
        privacyBgView.addSubview(notAgreeBtn)
        notAgreeBtn.snp.makeConstraints { make in
            make.top.equalTo(agreeBtn.snp.bottom).offset(Screen_IPadMultiply(10))
            make.centerX.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(25))
            make.width.equalTo(Screen_IPadMultiply(50))
        }
        notAgreeBtn.titleLabel?.font = Font_System_IPadMul(12)
        notAgreeBtn.setTitle("不同意".yjs_translateStr(), for: .normal)
        notAgreeBtn.setTitleColor(Color_Hex(0xBEBFC2), for: .normal)
        notAgreeBtn.addTarget(self, action: #selector(clickedBtnEvent(_:)), for: .touchUpInside)
    }
    
    func handleContent() -> NSMutableAttributedString {
        var contentStr = "天天有余非常重视您的个人信息和隐私保护。根据国家相关法律规定和标准更新了《天天有余APP用户协议》和《用户隐私政策》，请您在使用前仔细阅读并了解所有条款，包括：为向您提供包括账户注册、商品购物、交易支付在内的基本功能，我们可能会基于具体业务场景收集您的个人信息；我们会基于您的授权来为您提供更好的购物服务，这些授权包括定位（为您精确推荐相关的商品）、设备信息（为保障账户、交易安全及商品推荐，获取包括IMEI，IMSI在内的设备标识符）、您有权拒绝或取消这些授权；我们会基于先进的技术和管理措施保护您个人信息的安全；未经您的同意，我们不会将您的个人信息共享给第三方；为向您提供更好的服务，您同意提供及时、详尽准确的个人资料，并授权同意我们使用。如您不同意我们收集您的该等必要信息，您将无法享受由我们提供的该等业务功能；您在享用天天有余优质服务的同时，授权并同意接受向您的电子邮件、手机、通信地址等发送商业信息，包括但不限于最新的有余产品信息、促销信息等。若您选择不接受有余提供的各类信息服务，您可以按照有余提供的相应设置拒绝该类信息服务。".yjs_translateStr()
        if alertOrder != .first {
            contentStr = "根据相关法律规定，请您同意《天天有余APP用户协议》和《用户隐私政策》后再开始使用我们的应用服务。".yjs_translateStr()
        }
        let rangeTotal = NSRange(location: 0, length: contentStr.count)
        let userProtocalStr = "《天天有余APP用户协议》".yjs_translateStr()
        let userPrivateStr = "《用户隐私政策》".yjs_translateStr()
        let range1 = (contentStr as NSString).range(of: userProtocalStr)
        let range2 = (contentStr as NSString).range(of: userPrivateStr)
        let att = NSMutableAttributedString(string: contentStr, attributes: [.font: Font_Regular_IPadMul(13), .foregroundColor: Color_Hex(0x000000), .kern: 0])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Screen_IPadMultiply(2)
        att.addAttribute(.paragraphStyle, value: paragraphStyle, range: rangeTotal)
        let adFreeUrlStr = TYOnlineUrlHelper.getUserAgreementURL()
        let userPrivacyStr = TYOnlineUrlHelper.getPrivacyPolicyURL()
        if let adFreeURL = URL(string: adFreeUrlStr), let userPrivacyURL = URL(string: userPrivacyStr) {
            att.addAttribute(.link, value: adFreeURL, range: range1)
            att.addAttribute(.link, value: userPrivacyURL, range: range2)
            att.addAttribute(.underlineColor, value: Color_Hex(0xEE4745), range: range1)
            att.addAttribute(.underlineColor, value: Color_Hex(0xEE4745), range: range2)
            att.addAttribute(.foregroundColor, value: Color_Hex(0xEE4745), range: range1)
            att.addAttribute(.foregroundColor, value: Color_Hex(0xEE4745), range: range2)
        }
        return att
    }
    
    func updatePrivacyView(alertOrder: PrivacyAlertOrder) {
        self.alertOrder = alertOrder
        privacyBgView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(270))
            make.height.equalTo(Screen_IPadMultiply(240))
        }
        contentTextV.attributedText = handleContent()
        contentTextV.isScrollEnabled = false
        contentTextV.isEditable = false
        if alertOrder == .third {
            titleLb.text = "亲，要不在想想".yjs_translateStr()
            notAgreeBtn.setTitle("退出应用".yjs_translateStr(), for: .normal)
        } else if alertOrder == .second {
            titleLb.text = "温馨提示".yjs_translateStr()
            notAgreeBtn.setTitle("仍不同意".yjs_translateStr(), for: .normal)
        }
    }
    
    @objc func clickedBtnEvent(_ btn: UIButton) {
        if btn == agreeBtn {
            TYCacheHelper.cacheBool(value: true, for: kHasAgreePrivacyProtocolCacheKey)
            agreeClosure?()
        } else {
            if alertOrder == .first {
                updatePrivacyView(alertOrder: .second)
            } else if alertOrder == .second {
                updatePrivacyView(alertOrder: .third)
            } else {
                exit(0)
            }
        }
    }
}

extension TYPrivacyViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webVC = YJSWebStoreVC()
        webVC.originUrl = URL.absoluteString
        present(webVC, animated: true, completion: nil)
        return false
    }
}
