//
//  TYBindInviteCodeVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/8.
//

import UIKit
import BaseModule

class TYBindInviteCodeVC: TYBaseVC {
    // 标记是否从登录成功过来
    var isFromLogin: Bool = false
    
    private var textField = UITextField()
    private var bindBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        handleControllers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
}

private extension TYBindInviteCodeVC {
    
    func createSubviews() {
        setupNavBar()
        
        let tipLb = UILabel()
        tipLb.font = Font_Medium_IPadMul(30)
        tipLb.textColor = Color_Hex(0x262626)
        tipLb.text = "请输入邀请码".yjs_translateStr()
        view.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(45))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(70) + Screen_NavHeight)
        }
        
        view.addSubview(textField)
        textField.attributedPlaceholder = NSAttributedString(string: "输入邀请码".yjs_translateStr(), attributes: [.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0xBEBEBE)])
        textField.textColor = Color_Hex(0x262626)
        textField.font = Font_System_IPadMul(16)
        textField.tintColor = Color_Hex(0x262626)
        textField.becomeFirstResponder()
        textField.delegate = self
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(45))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-45))
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(80))
            make.height.equalTo(Screen_IPadMultiply(42))
        }
        
        let lineView = UIView()
        lineView.backgroundColor = Color_Hex(0xEBEBF0)
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.height.equalTo(Screen_IPadMultiply(0.5))
            make.top.equalTo(textField.snp.bottom)
        }
        
        bindBtn.setTitle("确认".yjs_translateStr(), for: .normal)
        bindBtn.setTitleColor(.white, for: .normal)
        bindBtn.titleLabel?.font = Font_Medium_IPadMul(18)
        bindBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        bindBtn.layer.cornerRadius = Screen_IPadMultiply(12)
        bindBtn.layer.masksToBounds = true
        bindBtn.isEnabled = false
        bindBtn.addTarget(self, action: #selector(bindBtnAction), for: .touchUpInside)
        view.addSubview(bindBtn)
        bindBtn.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.top.equalTo(lineView.snp.bottom).offset(Screen_IPadMultiply(29))
            make.height.equalTo(Screen_IPadMultiply(52))
        }
        
        let skipBtn = TYBindSkipButton(frame: CGRect(x: 0, y: 0, width: Screen_IPadMultiply(120), height: Screen_IPadMultiply(30)))
        skipBtn.titleLabel?.font = Font_System_IPadMul(14)
        skipBtn.setTitleColor(Color_Hex(0x999999), for: .normal)
        skipBtn.contentHorizontalAlignment = .right
        skipBtn.setTitle("跳过，先不绑".yjs_translateStr(), for: .normal)
        skipBtn.setImage(UIImage(named: "bind_skip_arrow"), for: .normal)
        skipBtn.addTarget(self, action: #selector(skipBtnAction), for: .touchUpInside)
        view.addSubview(skipBtn)
        skipBtn.snp.makeConstraints { make in
            make.right.equalTo(bindBtn)
            make.top.equalTo(bindBtn.snp.bottom).offset(Screen_IPadMultiply(24))
            make.width.equalTo(Screen_IPadMultiply(120))
            make.height.equalTo(Screen_IPadMultiply(30))
        }
        
    }
    
    @objc func bindBtnAction() {
        textField.resignFirstResponder()
        let code = textField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if code.isBlank {
            showToast(msg: "请输入邀请码")
            return
        }
        
        TYLoginService.bindPromoter(code: code) { [weak self] isSuccess, errorMsg in
            if isSuccess {
                self?.showToast(msg: "绑定邀请码成功")
                self?.skipBtnAction()
            } else {
                self?.showToast(msg: errorMsg)
            }
        }
    }
    
    @objc func skipBtnAction() {
        textField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    
    /// 如果从登录过来，需要移除登录控制器
    func handleControllers() {
        if isFromLogin == false {
            return
        }
        if var controllers = navigationController?.viewControllers, controllers.count > 2 {
            let readerVC = controllers[controllers.count - 2]
            if readerVC.isKind(of: TYLoginVC.self) {
                controllers.remove(readerVC)
            }
            navigationController?.viewControllers = controllers
        }
    }
}

extension TYBindInviteCodeVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldCount = textField.text?.count ?? 0
        let count = textFieldCount - range.length + string.count
        if count > 0 {
            bindBtn.isEnabled = true
        } else {
            bindBtn.isEnabled = false
        }
        return true
    }
}
