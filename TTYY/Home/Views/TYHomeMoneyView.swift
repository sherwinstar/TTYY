//
//  TYHomeMoneyView.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/31.
//

import UIKit
import BaseModule

class TYHomeMoneyView: UIView {
    var goLoginOrWithdrawClosure: (()->Void)?
    
    private var moneyLb = UILabel()
    private var moneyIcon = UIImageView()
    private var moneyBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMoneyView(_ totalMoney: Float) {
        if TYUserInfoHelper.userIsLogedIn() {
            moneyLb.text = "***"
            let money = modf(totalMoney)
            if money.1 != 0 {
                moneyLb.text = String(format: "%.02f", totalMoney)
            } else {
                moneyLb.text = "\(Int(totalMoney))"
            }
            moneyBtn.setTitle("预计可提现红包(元）", for: .normal)
            moneyBtn.setTitleColor(Color_Hex(0x595959), for: .normal)
        } else {
            moneyLb.text = "***"
            moneyBtn.setTitle("登录查看提现金额>", for: .normal)
            moneyBtn.setTitleColor(Color_Hex(0xE11521), for: .normal)
        }
    }
}

private extension TYHomeMoneyView {
    func createSubviews() {
        addSubview(moneyLb)
        moneyLb.text = "***"
        moneyLb.font = Font_Medium_IPadMul(34)
        moneyLb.textColor = Color_Hex(0x262626)
        moneyLb.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        
        addSubview(moneyBtn)
        moneyBtn.setTitleColor(Color_Hex(0xE11521), for: .normal)
        moneyBtn.setTitle("登录查看提现金额>", for: .normal)
        moneyBtn.titleLabel?.font = Font_Medium_IPadMul(16)
        moneyBtn.addTarget(self, action: #selector(goLoginOrWithdraw), for: .touchUpInside)
        moneyBtn.contentHorizontalAlignment = .left
        moneyBtn.snp.makeConstraints { make in
            make.top.equalTo(moneyLb.snp.bottom)
            make.width.equalTo(Screen_IPadMultiply(160))
            make.height.equalTo(Screen_IPadMultiply(22))
            make.left.equalToSuperview().offset(Screen_IPadMultiply(21))
        }
        
        addSubview(moneyIcon)
        moneyIcon.image = UIImage(named: "home_money_icon")
        moneyIcon.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(16))
            make.centerY.equalTo(moneyBtn)
            make.left.equalTo(moneyLb)
        }
    }
    
    @objc func goLoginOrWithdraw() {
        goLoginOrWithdrawClosure?()
    }
}
