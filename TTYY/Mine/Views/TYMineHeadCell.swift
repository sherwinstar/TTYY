//
//  TYMineHeadCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/10.
//

import UIKit
import BaseModule

enum HeadCellActionType {
    case setting // 设置
    case customer // 联系客服
    case bindCode   // 绑定邀请码
    case copyUserId // 复制userId
    case login // 登录
}

class TYMineHeadCell: UITableViewCell {
    
    /// 设置
    private var settingBtn = UIButton()
    /// 客服
    private var serviceBtn = UIButton()
    /// 用户头像
    private var userIconImgV = UIImageView()
    /// 用户名称
    private var userNameLb = UILabel()
    private var userNameAction = UIControl()
    
    /// 用户类型：合伙人还是普通用户
    private var userTypeLb = UILabel()
    /// 绑定邀请码
    private var bindCodeBtn = UIButton()
    /// 用户ID
    private var userIdLb = UILabel()
    /// 复制按钮
    private var copyBtn = UIButton()
    /// 已省钱提示
    private var tipLb = UILabel()
    
    private var saveMoney: Float = 0
    
    var headCellClosure: ((HeadCellActionType)->Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ allSaveMoney: Float) {
        saveMoney = allSaveMoney
        var tip = "已通过有余返利节省****元"
        let isLogin = TYUserInfoHelper.userIsLogedIn()
        if isLogin {
            tip = String(format: "已通过有余返利节省%.02f元", allSaveMoney)
        }
        handleSaveMoney(tip)
        refreshCell()
    }
}

private extension TYMineHeadCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        selectionStyle = .none
        contentView.addSubview(settingBtn)
        settingBtn.setImage(UIImage(named: "mine_setting_icon"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingBtnClick), for: .touchUpInside)
        settingBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-12))
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.width.height.equalTo(Screen_IPadMultiply(34))
        }
        
        contentView.addSubview(serviceBtn)
        serviceBtn.setImage(UIImage(named: "mine_answer_icon"), for: .normal)
        serviceBtn.addTarget(self, action: #selector(serviceBtnClick), for: .touchUpInside)
        serviceBtn.snp.makeConstraints { make in
            make.top.width.height.equalTo(settingBtn)
            make.right.equalTo(settingBtn.snp.left).offset(Screen_IPadMultiply(-5))
        }
        
        contentView.addSubview(userIconImgV)
        userIconImgV.layer.cornerRadius = Screen_IPadMultiply(22)
        userIconImgV.layer.masksToBounds = true
        userIconImgV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.top.equalTo(settingBtn.snp.bottom).offset(Screen_IPadMultiply(10))
            make.width.height.equalTo(Screen_IPadMultiply(44))
        }
        
        contentView.addSubview(userNameLb)
        userNameLb.textColor = Color_Hex(0x262626)
        userNameLb.font = Font_Medium_IPadMul(19)
        userNameLb.snp.makeConstraints { make in
            make.left.equalTo(userIconImgV.snp.right).offset(Screen_IPadMultiply(12))
            make.top.equalTo(settingBtn.snp.bottom).offset(Screen_IPadMultiply(7))
        }
        
        contentView.addSubview(userNameAction)
        userNameAction.addTarget(self, action: #selector(login), for: .touchUpInside)
        userNameAction.snp.makeConstraints { make in
            make.edges.equalTo(userNameLb)
        }
        
        contentView.addSubview(userTypeLb)
        userTypeLb.textColor = Color_Hex(0x8A93BE)
        userTypeLb.layer.borderWidth = 1
        userTypeLb.layer.borderColor = Color_Hex(0xA0A7C6).cgColor
        userTypeLb.layer.cornerRadius = Screen_IPadMultiply(2)
        userTypeLb.layer.masksToBounds = true
        userTypeLb.backgroundColor = .white
        userTypeLb.font = Font_Medium_IPadMul(10)
        userTypeLb.snp.makeConstraints { make in
            make.left.equalTo(userNameLb.snp.right).offset(Screen_IPadMultiply(5))
            make.centerY.equalTo(userNameLb)
            make.height.equalTo(Screen_IPadMultiply(17))
        }
        
        contentView.addSubview(bindCodeBtn)
        bindCodeBtn.addTarget(self, action: #selector(bindCodeBtnClick), for: .touchUpInside)
        bindCodeBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        bindCodeBtn.setTitleColor(Color_Hex(0x8A93BE), for: .normal)
        bindCodeBtn.setTitle("绑邀请码 >", for: .normal)
        bindCodeBtn.snp.makeConstraints { make in
            make.left.equalTo(userTypeLb.snp.right).offset(Screen_IPadMultiply(5))
            make.centerY.equalTo(userNameLb)
            make.width.equalTo(Screen_IPadMultiply(65))
            make.height.equalTo(Screen_IPadMultiply(17))
        }
        
        contentView.addSubview(userIdLb)
        userIdLb.snp.makeConstraints { make in
            make.left.equalTo(userNameLb)
            make.top.equalTo(userNameLb.snp.bottom).offset(Screen_IPadMultiply(7))
            make.width.equalTo(Screen_IPadMultiply(150))
            make.height.equalTo(Screen_IPadMultiply(20))
        }
        
        contentView.addSubview(copyBtn)
        copyBtn.addTarget(self, action: #selector(copyBtnClick), for: .touchUpInside)
        copyBtn.snp.makeConstraints { make in
            make.left.equalTo(userIdLb.snp.right).offset(Screen_IPadMultiply(5))
            make.centerY.equalTo(userIdLb)
            make.width.equalTo(Screen_IPadMultiply(30))
            make.height.equalTo(Screen_IPadMultiply(15))
        }
        
        contentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalTo(userNameLb)
            make.top.equalTo(userNameLb.snp.bottom).offset(Screen_IPadMultiply(30))
        }
        refreshCell()
    }
    
    func refreshCell() {
        let isLogin = TYUserInfoHelper.userIsLogedIn()
        var tip = "已通过有余返利节省****元"
        if isLogin {
            // 已经登录
            let headImg = TYUserInfoHelper.getUserHeadImgUrl()
            if headImg.isBlank {
                userIconImgV.image = UIImage(named: "mine_user_icon")
            } else {
                if let url = URL(string: headImg) {
                    userIconImgV.sd_setImage(with: url)
                }
            }
            userNameLb.text = TYUserInfoHelper.getUserName()
            userNameAction.isHidden = true
            userTypeLb.isHidden = false
            userTypeLb.text = TYUserInfoHelper.getUserTypeString()
            bindCodeBtn.isHidden = TYUserInfoHelper.getUserIsBindInviteCode()
            
            userIdLb.isHidden = false
            let userId = TYUserInfoHelper.getUserId()
            let userIdTip = "用户ID：" + userId
            let att = NSMutableAttributedString(string: userIdTip)
            att.addAttributes([.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0x595959)], range: NSRange(location: 0, length: 5))
            att.addAttributes([.font: Font_Medium_IPadMul(14), .foregroundColor: Color_Hex(0x4E567D)], range: NSRange(location: 5, length: userIdTip.count - 5))
            userIdLb.attributedText = att
            
            copyBtn.isHidden = false
            let copyAtt = NSMutableAttributedString(string: "复制")
            copyAtt.addAttributes([.font: Font_Medium_IPadMul(12), .foregroundColor: Color_Hex(0xE11521), .underlineColor: Color_Hex(0xE11521), .underlineStyle:  NSUnderlineStyle.single.rawValue], range: NSRange(location: 0, length: 2))
            copyBtn.setAttributedTitle(copyAtt, for: .normal)
            tip = String(format: "已通过有余返利节省%.01f元", saveMoney)
            tipLb.snp.remakeConstraints { make in
                make.left.equalTo(userNameLb)
                make.top.equalTo(userNameLb.snp.bottom).offset(Screen_IPadMultiply(30))
            }
        } else {
            // 未登录
            userIconImgV.image = UIImage(named: "mine_user_icon")
            userNameLb.text = "立即登录"
            userNameAction.isHidden = false
            userTypeLb.isHidden = true
            bindCodeBtn.isHidden = true
            userIdLb.isHidden = true
            copyBtn.isHidden = true
            
            tipLb.snp.remakeConstraints { make in
                make.left.equalTo(userNameLb)
                make.top.equalTo(userNameLb.snp.bottom).offset(Screen_IPadMultiply(4))
            }
        }
        handleSaveMoney(tip)
    }
    
    func handleSaveMoney(_ tip: String) {
        let att = NSMutableAttributedString(string: tip)
        att.addAttributes([.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0x595959)], range: NSRange(location: 0, length: 9))
        att.addAttributes([.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0x595959)], range: NSRange(location: tip.count - 1, length: 1))
        att.addAttributes([.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 9, length: tip.count - 10))
        tipLb.attributedText = att
    }
    
    /// 设置
    @objc func settingBtnClick() {
        headCellClosure?(.setting)
    }
    
    /// 客服
    @objc func serviceBtnClick() {
        headCellClosure?(.customer)
    }
    
    /// 绑定邀请码
    @objc func bindCodeBtnClick() {
        headCellClosure?(.bindCode)
    }
    
    /// 复制
    @objc func copyBtnClick() {
        headCellClosure?(.copyUserId)
    }
    
    /// 登录
    @objc func login() {
        headCellClosure?(.login)
    }
}
