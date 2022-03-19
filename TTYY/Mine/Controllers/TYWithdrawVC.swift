//
//  TYWithdrawVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/13.
//

import UIKit
import BaseModule
import YJSWebModule

class TYWithdrawVC: TYBaseVC {
    
    private var priceLb = UILabel()
    private var moneyBg = UIView()
    private var inputBg = UIView()
    private var moneyTF = UITextField()
    private var withdrawBtn = UIButton()
    
    /// 可以提现金额
    private var money: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        requestMoneyInfo()
    }
    
    override func onRightClicked(at index: Int) {
        goWebView(url: TYOnlineUrlHelper.getWithdrawRuleURL())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moneyTF.resignFirstResponder()
    }
}

private extension TYWithdrawVC {
    func requestMoneyInfo() {
        showProgress()
        TYMineService.getUserRebateInfo { [weak self] isSuccess, info in
            self?.hideProgress()
            if let model = info, isSuccess {
                self?.money = model.remainMoney
            } else {
                self?.money = 0
            }
            self?.updatePriceLb()
        }
    }
    
    func updatePriceLb() {
        priceLb.text = String(format: "%.02f", money)
    }
}

private extension TYWithdrawVC {
    func createSubviews() {
        setupNavBar(title: "提现")
        setupRightBarItems(titles: ["规则"])
        view.backgroundColor = Color_Hex(0xF8F8F8)
        createTipContentView()
        createMoneyView()
        createInputView()
        createBottomView()
    }
    
    func createTipContentView() {
        let tipContentView = UIView()
        view.addSubview(tipContentView)
        tipContentView.backgroundColor = Color_Hex(0xFFF9E0)
        tipContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_NavHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(36))
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
        tipLb.text = "每月25号后可提现上月已结算收益".yjs_translateStr()
        tipLb.font = Font_System_IPadMul(14)
        tipContentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalTo(iconImg.snp.right).offset(Screen_IPadMultiply(6))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-15))
            make.centerY.equalTo(iconImg)
        }
    }
    
    func createMoneyView() {
        moneyBg.backgroundColor = Color_Hex(0xDBD7D7)
        view.addSubview(moneyBg)
        moneyBg.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavHeight + Screen_IPadMultiply(36))
            make.height.equalTo(Screen_IPadMultiply(119))
        }
        
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x595959)
        tipLb.text = "可提现(元)"
        tipLb.font = Font_System_IPadMul(14)
        moneyBg.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(31))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(18))
        }
        
        moneyBg.addSubview(priceLb)
        priceLb.font = Font_Bebas(34)
        priceLb.textColor = Color_Hex(0x262626)
        priceLb.snp.makeConstraints { make in
            make.left.equalTo(tipLb)
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(4))
        }
        priceLb.text = "0"
    }
    
    func createInputView() {
        view.addSubview(inputBg)
        inputBg.backgroundColor = .white
        inputBg.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moneyBg.snp.bottom)
            make.height.equalTo(Screen_IPadMultiply(138))
        }
        
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x262626)
        tipLb.font = Font_System_IPadMul(16)
        tipLb.text = "提现金额"
        inputBg.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(23))
        }
        
        let moneySymbol = UILabel()
        moneySymbol.text = "￥"
        moneySymbol.textColor = Color_Hex(0x262626)
        moneySymbol.font = Font_Medium_IPadMul(30)
        inputBg.addSubview(moneySymbol)
        moneySymbol.snp.makeConstraints { make in
            make.left.equalTo(tipLb)
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(20))
            make.height.equalTo(Screen_IPadMultiply(42))
        }
        
        
        inputBg.addSubview(moneyTF)
        moneyTF.font = Font_Bebas(34)
        moneyTF.attributedPlaceholder = NSAttributedString(string: "请输入提现金额".yjs_translateStr(), attributes: [.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0xBEBEBE)])
        moneyTF.textColor = Color_Hex(0xE11521)
        moneyTF.tintColor = Color_Hex(0x262626)
        moneyTF.delegate = self
        moneyTF.keyboardType = .decimalPad
        moneyTF.snp.makeConstraints { make in
            make.left.equalTo(moneySymbol.snp.right).offset(Screen_IPadMultiply(8))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-15))
            make.height.equalTo(Screen_IPadMultiply(42))
            make.bottom.equalTo(moneySymbol)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = Color_Hex(0xCCCCCC)
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-15))
            make.height.equalTo(Screen_IPadMultiply(0.5))
            make.top.equalTo(moneyTF.snp.bottom)
        }
        
        let ruleLb = UILabel()
        ruleLb.textColor = Color_Hex(0x999999)
        ruleLb.font = Font_System_IPadMul(12)
        ruleLb.text = "*最低提现金额5元".yjs_translateStr()
        inputBg.addSubview(ruleLb)
        ruleLb.snp.makeConstraints { make in
            make.left.equalTo(lineView)
            make.right.equalTo(lineView)
            make.top.equalTo(lineView.snp.bottom).offset(Screen_IPadMultiply(8))
        }
    }
    
    func createBottomView() {
        view.addSubview(withdrawBtn)
        withdrawBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        withdrawBtn.setTitleColor(.white, for: .normal)
        withdrawBtn.titleLabel?.font = Font_Medium_IPadMul(18)
        withdrawBtn.setTitle("立即提现", for: .normal)
        withdrawBtn.layer.cornerRadius = Screen_IPadMultiply(12)
        withdrawBtn.layer.masksToBounds = true
        var btnW = Screen_Width - Screen_IPadMultiply(30)
        if btnW > Screen_IPadMultiply(345) {
            btnW = Screen_IPadMultiply(345)
        }
        withdrawBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(inputBg.snp.bottom).offset(Screen_IPadMultiply(28))
            make.height.equalTo(Screen_IPadMultiply(52))
            make.width.equalTo(btnW)
        }
        withdrawBtn.isEnabled = false
        withdrawBtn.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        
        let accountSetBtn = UIButton()
        accountSetBtn.setTitleColor(Color_Hex(0x999999), for: .normal)
        accountSetBtn.setTitle("提现账户设置", for: .normal)
        accountSetBtn.titleLabel?.font = Font_System_IPadMul(14)
        view.addSubview(accountSetBtn)
        accountSetBtn.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(278))
            make.top.equalTo(withdrawBtn.snp.bottom).offset(Screen_IPadMultiply(10))
            make.height.equalTo(Screen_IPadMultiply(20))
            make.centerX.equalToSuperview()
        }
        accountSetBtn.addTarget(self, action: #selector(accountSetting), for: .touchUpInside)
        
        let lineView = UIView()
        lineView.backgroundColor = Color_Hex(0x999999)
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(20))
            make.width.equalTo(Screen_IPadMultiply(1))
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
        
        
        let questionBtn = UIButton()
        questionBtn.titleLabel?.font = Font_System_IPadMul(14)
        questionBtn.setTitle("常见问题", for: .normal)
        questionBtn.setTitleColor(Color_Hex(0x999999), for: .normal)
        questionBtn.contentHorizontalAlignment = .right
        view.addSubview(questionBtn)
        questionBtn.snp.makeConstraints { make in
            make.right.equalTo(lineView.snp.left).offset(Screen_IPadMultiply(-5))
            make.centerY.equalTo(lineView)
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(120), height: Screen_IPadMultiply(20)))
        }
        questionBtn.addTarget(self, action: #selector(questionAction), for: .touchUpInside)
        
        let detailBtn = UIButton()
        detailBtn.titleLabel?.font = Font_System_IPadMul(14)
        detailBtn.setTitle("收益明细", for: .normal)
        detailBtn.setTitleColor(Color_Hex(0x999999), for: .normal)
        detailBtn.contentHorizontalAlignment = .left
        view.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(Screen_IPadMultiply(5))
            make.centerY.equalTo(lineView)
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(120), height: Screen_IPadMultiply(20)))
        }
        detailBtn.addTarget(self, action: #selector(detailBtnAction), for: .touchUpInside)
    }
    
    func goWebView(url: String) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        navigationController?.pushViewController(web, animated: true)
    }
    
    @objc func withdrawAction() {
        guard let input = Double(moneyTF.text ?? "") else {
            return
        }
        if TYUserInfoHelper.userIsLogedIn() {
            if TYUserInfoHelper.getUserIsBindAlipay() {
                withdraw(input)
            } else {
                let aliPaySetting = TYAliPaySettingVC()
                navigationController?.pushViewController(aliPaySetting, animated: true)
            }
            
        } else {
            let vc = TYLoginVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func withdraw(_ input: Double) {
        showProgress()
        TYMineService.withdraw(money: input) { [weak self] isSuccess, msg in
            self?.hideProgress()
            if isSuccess {
                self?.requestMoneyInfo()
                self?.goWebView(url: TYOnlineUrlHelper.getWithdrawstatussuccessURL())
            } else {
                self?.showToast(msg: msg)
            }
        }
    }
    
    @objc func accountSetting() {
        let aliPaySetting = TYAliPaySettingVC()
        navigationController?.pushViewController(aliPaySetting, animated: true)
    }
    
    @objc func questionAction() {
        goWebView(url: TYOnlineUrlHelper.getWithdrawQAURL())
    }
    
    @objc func detailBtnAction() {
        goWebView(url: TYOnlineUrlHelper.getTransactionRecordsURL())
    }
}

extension TYWithdrawVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 1, range.location == 0 {
            withdrawBtn.isEnabled = false
            return true
        }
        var strValue = (textField.text ?? "") + string
        if range.length == 1 {
            strValue = strValue.sub(to: range.location) ?? ""
        }
        print(strValue)
        let value = (strValue as NSString).floatValue
        if money >= 0, value > money {
            return false
        }
        
        if value < 5 {
            withdrawBtn.isEnabled = false
            return true
        }
        let dotRange = strValue.range(of: ".")
        if dotRange == nil || dotRange!.isEmpty {
            withdrawBtn.isEnabled = true
            return true
        }
        var dotIndex = -1;
        for index in 0..<strValue.count {
            let char = strValue[strValue.index(strValue.startIndex, offsetBy: index)]
            if char == "." {
                dotIndex = index
                break
            }
        }
        if dotIndex > -1, strValue.count - dotIndex - 1 > 2 {
            return false
        }
        withdrawBtn.isEnabled = true
        return true
    }
}
