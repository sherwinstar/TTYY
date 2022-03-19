//
//  TYAliPaySettingVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/9.
//

import UIKit
import BaseModule

class TYAliPaySettingVC: TYBaseVC {
    private lazy var tipContentView = UIView()
    /// 支付宝账号
    private var accountTF = UITextField()
    /// 姓名
    private var nameTF = UITextField()
    /// 身份证号
    private var idCardTF = UITextField()
    
    private var detailLb = UILabel()
    /// 提交按钮
    private var submitBtn = UIButton()
    
    private var isBind = TYUserInfoHelper.getUserIsBindAlipay()
    
    private var oldAccount = TYUserInfoHelper.getUserAlipayAccount()
    private var oldName = TYUserInfoHelper.getUserIdCardName()
    private var oldIdCardNum = TYUserInfoHelper.getUserIdCardNum()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        addObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI
private extension TYAliPaySettingVC {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(noti:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    func createSubviews() {
        setupNavBar(title: "支付宝提现设置")
        createTipContentView()
        createAlipayIcon()
        createAlipayInputView()
        createDetailInfo()
        createSubmitBtn()
    }
    
    func createTipContentView() {
        if isBind {
            // 如果已经绑定支付宝，这部分UI就不需要了
            return
        }
        
        view.addSubview(tipContentView)
        tipContentView.backgroundColor = Color_Hex(0xFFF9E0)
        tipContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_NavHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(56))
        }
        
        let iconImg = UIImageView(image: UIImage(named: "bind_alipay_tip_icon"))
        tipContentView.addSubview(iconImg)
        iconImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.width.height.equalTo(Screen_IPadMultiply(16))
        }
        
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0xFF8B00)
        tipLb.text = "你还没绑定支付宝信息，绑定并提交后提现金额将转入该支付宝账户".yjs_translateStr()
        tipLb.numberOfLines = 2
        tipLb.font = Font_System_IPadMul(14)
        tipContentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalTo(iconImg.snp.right).offset(Screen_IPadMultiply(6))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-15))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(8))
        }
    }
    
    func createAlipayIcon() {
        let iconImg = UIImageView(image: UIImage(named: "bind_alipay_icon"))
        view.addSubview(iconImg)
        iconImg.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(61))
            if self.isBind {
                make.top.equalToSuperview().offset(Screen_IPadMultiply(103) + Screen_NavHeight)
            } else {
                make.top.equalTo(tipContentView.snp.bottom).offset(Screen_IPadMultiply(47))
            }
            make.centerX.equalToSuperview()
        }
    }
    
    func createAlipayInputView() {
        let tip1 = createTipLabel(text: "账号")
        view.addSubview(tip1)
        tip1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            if self.isBind {
                make.top.equalToSuperview().offset(Screen_IPadMultiply(205) + Screen_NavHeight)
            } else {
                make.top.equalTo(tipContentView.snp.bottom).offset(Screen_IPadMultiply(149))
            }
        }
        
        view.addSubview(accountTF)
        updateTextField(ft: accountTF, placeholder: "输入支付宝账号")
        if isBind {
            accountTF.text = oldAccount
        }
        accountTF.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(121))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.centerY.equalTo(tip1)
            make.height.equalTo(Screen_IPadMultiply(48))
        }
        
        let line1 = createLineView()
        view.addSubview(line1)
        line1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.height.equalTo(Screen_IPadMultiply(0.5))
            make.top.equalTo(accountTF.snp.bottom)
        }
        
        let tip2 = createTipLabel(text: "姓名")
        view.addSubview(tip2)
        tip2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.top.equalTo(line1.snp.bottom).offset(Screen_IPadMultiply(13))
        }
        
        view.addSubview(nameTF)
        updateTextField(ft: nameTF, placeholder: "输入真实姓名")
        if isBind {
            nameTF.text = oldName
        }
        nameTF.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(121))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.centerY.equalTo(tip2)
            make.height.equalTo(Screen_IPadMultiply(48))
        }
        
        let line2 = createLineView()
        view.addSubview(line2)
        line2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.height.equalTo(Screen_IPadMultiply(0.5))
            make.top.equalTo(nameTF.snp.bottom)
        }
        
        let tip3 = createTipLabel(text: "身份证号")
        view.addSubview(tip3)
        tip3.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.top.equalTo(line2.snp.bottom).offset(Screen_IPadMultiply(13))
        }
        
        view.addSubview(idCardTF)
        updateTextField(ft: idCardTF, placeholder: "输入身份证号")
        if isBind {
            idCardTF.text = oldIdCardNum
        }
        idCardTF.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(121))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.centerY.equalTo(tip3)
            make.height.equalTo(Screen_IPadMultiply(48))
        }
        
        let line3 = createLineView()
        view.addSubview(line3)
        line3.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.height.equalTo(Screen_IPadMultiply(0.5))
            make.top.equalTo(idCardTF.snp.bottom)
        }
    }
    
    func createTipLabel(text: String) -> UILabel {
        let tip = UILabel()
        tip.font = Font_System_IPadMul(16)
        tip.textColor = .black
        tip.text = text.yjs_translateStr()
        return tip
    }
    
    func updateTextField(ft: UITextField, placeholder: String) {
        ft.attributedPlaceholder = NSAttributedString(string: placeholder.yjs_translateStr(), attributes: [.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0xBEBEBE)])
        ft.textColor = Color_Hex(0x262626)
        ft.font = Font_System_IPadMul(16)
        ft.tintColor = Color_Hex(0x262626)
        ft.delegate = self
    }
    
    func createLineView() -> UIView {
        let line = UIView()
        line.backgroundColor = Color_Hex(0xEBEBF0)
        return line
    }
    
    func createDetailInfo() {
        detailLb.text = "为了您能成功提现，请确保此处填写的「实名身份信息」真实无误。 如果您将要使用微信提现功能，需要确认此处的「实名身份信息」 与您微信账号中「实名身份信息」一致，否则会提现失败。".yjs_translateStr()
        detailLb.font = Font_System_IPadMul(10)
        detailLb.textColor = Color_Hex(0xB7B7BD)
        detailLb.numberOfLines = 0
        view.addSubview(detailLb)
        detailLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.top.equalTo(idCardTF.snp.bottom).offset(Screen_IPadMultiply(26))
        }
    }
    
    func createSubmitBtn() {
        view.addSubview(submitBtn)
        submitBtn.setTitle("确认并提交".yjs_translateStr(), for: .normal)
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.titleLabel?.font = Font_Medium_IPadMul(18)
        submitBtn.layer.cornerRadius = Screen_IPadMultiply(12)
        submitBtn.layer.masksToBounds = true
        submitBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        submitBtn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        submitBtn.isEnabled = false
        submitBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(43))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-43))
            make.top.equalTo(detailLb.snp.bottom).offset(Screen_IPadMultiply(23))
            make.height.equalTo(Screen_IPadMultiply(52))
        }
    }
}

private extension TYAliPaySettingVC {
    @objc func submitAction() {
        view.endEditing(true)
        let accountText = accountTF.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        let nameText = nameTF.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        let idCardText = idCardTF.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if accountText.isBlank {
            showToast(msg: "请输入支付宝账号".yjs_translateStr())
            return
        }
        if nameText.isBlank {
            showToast(msg: "请输入姓名".yjs_translateStr())
            return
        }
        if idCardText.isBlank {
            showToast(msg: "请输入身份证号".yjs_translateStr())
            return
        }
        if accountText == oldAccount, nameText == oldName, idCardText == oldIdCardNum {
            showToast(msg: "没有修改，不用提交".yjs_translateStr())
            return
        }
        
        if !validateIdCardNum(careNum: idCardText) {
            showToast(msg: "请输入正确的身份证号")
            return
        }
        showProgress()
        TYLoginService.bindAlipay(account: accountText, idCard: idCardText, name: nameText) { [weak self] isSuccess, errorMsg in
            self?.hideProgress()
            if isSuccess {
                self?.showToast(msg: "绑定成功")
                self?.navigationController?.popViewController(animated: true)
                TYLoginService.loginFromLaunch(completeHandler: nil)
            } else {
                self?.showToast(msg: errorMsg)
            }
        }
    }
    
    /// 验证身份证格式(不是身份证规则是否合法)
    func validateIdCardNum(careNum: String) -> Bool {
            let cardRegex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
            let cardTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", cardRegex)
        return cardTest.evaluate(with: careNum)
    }
    
    /// 键盘
    @objc func keyboardDidChangeFrame(noti: Notification) {
        guard let userInfo = noti.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyY = frame.origin.y
        let submitBtnBottom = submitBtn.swift_bottom
        var offset: CGFloat = 0
        if keyY < submitBtnBottom {
            offset = keyY - submitBtnBottom - 10
        }
        let keyDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0
        UIView.animate(withDuration: TimeInterval(keyDuration)) {
            self.view.transform = CGAffineTransform(translationX: 0, y: offset)
        }
    }
}

extension TYAliPaySettingVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var otherTF1: UITextField
        var otherTF2: UITextField
        if textField == accountTF {
            otherTF1 = nameTF
            otherTF2 = idCardTF
        } else if textField == nameTF {
            otherTF1 = accountTF
            otherTF2 = idCardTF
        } else {
            otherTF1 = accountTF
            otherTF2 = nameTF
        }
        let textFieldCount = textField.text?.count ?? 0
        let count = textFieldCount - range.length + string.count
        let text1 = otherTF1.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        let text2 = otherTF2.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if count > 0, !text1.isBlank, !text2.isBlank {
            submitBtn.isEnabled = true
        } else {
            submitBtn.isEnabled = false
        }
        return true
    }
}
