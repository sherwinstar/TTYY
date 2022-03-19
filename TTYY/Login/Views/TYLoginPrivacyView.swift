//
//  TYLoginPrivacyView.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/6.
//

import UIKit
import YJSWebModule
import BaseModule

class TYLoginPrivacyView: UIView {
    private var privacyTextV = UITextView()
    private var selectBtn: UIButton = UIButton()
    
    var isSelected: Bool {
        get {
            return selectBtn.isSelected
        }
        set {
            selectBtn.isSelected = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == nil {
            for subView in subviews {
                let p = subView.convert(point, from: self)
                if subView.bounds.contains(p) {
                    view = subView
                }
            }
        }
        return view
    }
}

private extension TYLoginPrivacyView {
    func createSubViews() {
        addSubview(selectBtn)
        selectBtn.setImage(UIImage(named: "login_privacy_unselected"), for: .normal)
        selectBtn.setImage(UIImage(named: "login_privacy_selected"), for: .selected)
        selectBtn.addTarget(self, action: #selector(selectBtnClicked), for: .touchUpInside)
        selectBtn.snp.makeConstraints { make in
            if Screen_IPAD {
                make.centerY.equalToSuperview().offset(-2)
            } else {
                make.centerY.equalTo(self.snp.top).offset(Screen_IPadMultiply(8))
            }
            make.centerX.equalTo(snp.left).offset(6)
            make.width.height.equalTo(30)
        }
        
        createTextV()
    }
    
    func createTextV() {
        addSubview(privacyTextV)
        privacyTextV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(selectBtn.snp.centerX).offset(14)
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-24))
        }
        
        let privacyStr = "登录代表您已详细阅读、理解并同意《天天有余APP用户协议》和《用户隐私政策》".yjs_translateStr()
        let match1 = "《天天有余APP用户协议》".yjs_translateStr()
        let match2 = "《用户隐私政策》".yjs_translateStr()
        let attrStr = NSMutableAttributedString(string: privacyStr, attributes: [NSAttributedString.Key.font: Font_System_IPadMul(12), NSAttributedString.Key.foregroundColor: Color_Hex(0x999999)])
        if let range = privacyStr.range(of: match1) {
            let nsRange = NSRange(range, in: privacyStr)
            let urlStr = TYOnlineUrlHelper.getUserAgreementURL()
            if let url = URL(string: urlStr) {
                attrStr.addAttributes([.link: url, .underlineColor: Color_Hex(0x999999)], range: nsRange)
            }
        }
        if let range = privacyStr.range(of: match2) {
            let nsRange = NSRange(range, in: privacyStr)
            let urlStr = TYOnlineUrlHelper.getPrivacyPolicyURL()
            if let url = URL(string: urlStr) {
                attrStr.addAttributes([.link: url, .underlineColor: Color_Hex(0x999999)], range: nsRange)
            }
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: privacyStr.count))
        privacyTextV.delegate = self
        privacyTextV.attributedText = attrStr
        privacyTextV.isScrollEnabled = false
        privacyTextV.isEditable = false
        privacyTextV.linkTextAttributes = [.underlineStyle: NSNumber(integerLiteral: 1)]
        privacyTextV.textContainerInset = .zero
        privacyTextV.textContainer.lineFragmentPadding = 0
    }
}

private extension TYLoginPrivacyView {
    @objc func selectBtnClicked() {
        selectBtn.isSelected = !selectBtn.isSelected
    }
}

extension TYLoginPrivacyView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webVC = YJSWebStoreVC()
        webVC.originUrl = URL.absoluteString
        UIApplication.getCurrentVC()?.navigationController?.pushViewController(webVC, animated: true)
        return false
    }
}
