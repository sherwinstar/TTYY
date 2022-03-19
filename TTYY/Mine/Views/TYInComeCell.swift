//
//  TYInComeCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/10.
//

import UIKit
import BaseModule

enum InComeActionType {
    case login // 登录
    case drawMoney  // 提现
    case drawShell  // 兑换贝壳
    case goGame // 赚贝壳
}

class TYInComeCell: UITableViewCell {
    private var topImgV = UIImageView()
    /// 总收益
    private var allMoneyLb = UILabel()
    private var leftMoneyLb = UILabel()
    private var rightMoneyLb = UILabel()
    
    /// 贝壳相关背景
    private var bottomImgV = UIImageView()
    /// 贝壳数量
    private var bekeLb = UILabel()
    
    private var rebateInfo: TYRebateInfoModel?
    var inComeClosure: ((InComeActionType)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ info: TYRebateInfoModel?) {
        rebateInfo = info
        if contentView.swift_height == Screen_IPadMultiply(160) {
            bottomImgV.isHidden = true
        } else {
            bottomImgV.isHidden = false
        }
        refreshCell()
    }
}

private extension TYInComeCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        selectionStyle = .none
        contentView.addSubview(topImgV)
        topImgV.image = UIImage(named: "mine_money_top")
        topImgV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-10))
            make.height.equalTo(Screen_IPadMultiply(160))
        }
        topImgV.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        topImgV.addGestureRecognizer(tap)
        
        let tipLb = UILabel()
        topImgV.addSubview(tipLb)
        tipLb.font = Font_Medium_IPadMul(14)
        tipLb.text = "我的红包(元)"
        tipLb.textColor = Color_Hex(0x595959)
        tipLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(15))
        }
        
        topImgV.addSubview(allMoneyLb)
        allMoneyLb.textColor = Color_Hex(0xE11521)
        allMoneyLb.font = Font_Bebas(34)
        allMoneyLb.textAlignment = .center
        allMoneyLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLb.snp.bottom)
        }
        
        let tipView = UIView()
        topImgV.addSubview(tipView)
        tipView.isUserInteractionEnabled = false
        let lbBounds = CGRect(x: 0, y: 0, width: Screen_IPadMultiply(54), height: Screen_IPadMultiply(18))
        tipView.bounds = lbBounds
        tipView.roundCorners([.topLeft, .topRight, .bottomRight], radius: Screen_IPadMultiply(9))
        
        let layer = CAGradientLayer.init()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.colors = [Color_Hex(0x73C764).cgColor, Color_Hex(0x10CD71).cgColor]
        layer.frame = lbBounds
        tipView.layer.addSublayer(layer)
        tipView.snp.makeConstraints { (make) in
            make.centerY.equalTo(allMoneyLb.snp.centerY).offset(Screen_IPadMultiply(-12))
            make.left.equalTo(allMoneyLb.snp.right).offset(Screen_IPadMultiply(10))
            make.height.equalTo(Screen_IPadMultiply(18))
            make.width.equalTo(Screen_IPadMultiply(54))
        }
        
        let moneyTipLb = UILabel()
        moneyTipLb.text = "0手续费".yjs_translateStr()
        moneyTipLb.textAlignment = .center
        moneyTipLb.textColor = .white
        moneyTipLb.font = Font_Medium_IPadMul(10)
        tipView.addSubview(moneyTipLb)
        moneyTipLb.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = Color_Hex(0xA7A7A7)
        topImgV.addSubview(line)
        line.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-22))
            make.width.equalTo(Screen_IPadMultiply(0.5))
            make.height.equalTo(Screen_IPadMultiply(32))
            make.centerX.equalToSuperview()
        }
        
        let leftTipLb = UILabel()
        leftTipLb.text = "本月预估收入(元)"
        leftTipLb.font = Font_System_IPadMul(12)
        leftTipLb.textColor = Color_Hex(0x595959)
        leftTipLb.textAlignment = .center
        topImgV.addSubview(leftTipLb)
        leftTipLb.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(line.snp.left)
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-17))
        }
        
        topImgV.addSubview(leftMoneyLb)
        leftMoneyLb.font = Font_Bebas(20)
        leftMoneyLb.textColor = Color_Hex(0x595959)
        leftMoneyLb.textAlignment = .center
        leftMoneyLb.snp.makeConstraints { make in
            make.left.right.equalTo(leftTipLb)
            make.bottom.equalTo(leftTipLb.snp.top).offset(Screen_IPadMultiply(-6))
        }
        
        let rightTipLb = UILabel()
        rightTipLb.text = "可提现金额(元)>"
        rightTipLb.font = Font_System_IPadMul(12)
        rightTipLb.textColor = Color_Hex(0x595959)
        rightTipLb.textAlignment = .center
        topImgV.addSubview(rightTipLb)
        rightTipLb.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(line.snp.right)
            make.bottom.equalTo(leftTipLb)
        }
        
        topImgV.addSubview(rightMoneyLb)
        rightMoneyLb.font = Font_Bebas(20)
        rightMoneyLb.textColor = Color_Hex(0x595959)
        rightMoneyLb.textAlignment = .center
        rightMoneyLb.snp.makeConstraints { make in
            make.left.right.equalTo(rightTipLb)
            make.bottom.equalTo(rightTipLb.snp.top).offset(Screen_IPadMultiply(-6))
        }
        
        contentView.addSubview(bottomImgV)
        bottomImgV.image = UIImage(named: "mine_money_bottom")
        bottomImgV.isUserInteractionEnabled = true
        bottomImgV.snp.makeConstraints { make in
            make.left.right.equalTo(topImgV)
            make.bottom.equalToSuperview()
            make.top.equalTo(topImgV.snp.bottom)
        }
        
        let bottomTap = UITapGestureRecognizer(target: self, action: #selector(bottomTapAction))
        bottomImgV.addGestureRecognizer(bottomTap)
        
        let bottomTipLb = UILabel()
        bottomTipLb.font = Font_Medium_IPadMul(14)
        bottomTipLb.textColor = Color_Hex(0x595959)
        bottomTipLb.textAlignment = .left
        bottomTipLb.text = "我的贝壳"
        bottomImgV.addSubview(bottomTipLb)
        bottomTipLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(15))
        }
        
        bottomImgV.addSubview(bekeLb)
        bekeLb.font = Font_Bebas(24)
        bekeLb.textColor = Color_Hex(0x595959)
        bekeLb.snp.makeConstraints { make in
            make.left.equalTo(bottomTipLb)
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-18))
        }
        
        let bekeImg = UIImageView(image: UIImage(named: "mine_beke_icon"))
        bottomImgV.addSubview(bekeImg)
        bekeImg.snp.makeConstraints { make in
            make.left.equalTo(bekeLb.snp.right).offset(Screen_IPadMultiply(3))
            make.bottom.equalTo(bekeLb.snp.bottom).offset(Screen_IPadMultiply(-3))
            make.width.equalTo(Screen_IPadMultiply(18))
            make.height.equalTo(Screen_IPadMultiply(15))
        }
        
        let convertBtn = UIButton()
        convertBtn.setTitle("去兑换".yjs_translateStr(), for: .normal)
        convertBtn.setTitleColor(Color_Hex(0x0081FC), for: .normal)
        convertBtn.titleLabel?.font = Font_System_IPadMul(12)
        convertBtn.addTarget(self, action: #selector(goConvert), for: .touchUpInside)
        bottomImgV.addSubview(convertBtn)
        convertBtn.snp.makeConstraints { make in
            make.left.equalTo(bekeImg.snp.right).offset(Screen_IPadMultiply(19))
            make.bottom.equalTo(bekeLb.snp.bottom)
            make.height.equalTo(Screen_IPadMultiply(20))
            make.width.equalTo(Screen_IPadMultiply(42))
        }
        
        let arrowImg = UIImageView(image: UIImage(named: "mine_beke_more"))
        bottomImgV.addSubview(arrowImg)
        arrowImg.snp.makeConstraints { make in
            make.centerY.equalTo(convertBtn)
            make.left.equalTo(convertBtn.snp.right)
        }
        
        let makeBtn = UIButton()
        makeBtn.setTitle("去赚贝壳", for: .normal)
        makeBtn.setTitleColor(Color_Hex(0x0081FC), for: .normal)
        makeBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        makeBtn.layer.borderColor = Color_Hex(0x0081FC).cgColor
        makeBtn.layer.borderWidth = 1
        makeBtn.layer.cornerRadius = Screen_IPadMultiply(6)
        bottomImgV.addSubview(makeBtn)
        makeBtn.addTarget(self, action: #selector(goMakeBeke), for: .touchUpInside)
        makeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-25))
            make.width.equalTo(Screen_IPadMultiply(65))
            make.height.equalTo(Screen_IPadMultiply(28))
        }
        
        refreshCell()
    }
    
    func refreshCell() {
        let isLogin = TYUserInfoHelper.userIsLogedIn()
        if let info = rebateInfo, isLogin {
            allMoneyLb.text = String(format: "%.02f", info.remainMoney + info.rebateMoney)
            leftMoneyLb.text = String(format: "%.02f", info.rebateMoney)
            rightMoneyLb.text = String(format: "%.02f", info.remainMoney)
            bekeLb.text = "\(info.remainConch)"
        } else {
            allMoneyLb.text = "***"
            leftMoneyLb.text = "***"
            rightMoneyLb.text = "***"
            bekeLb.text = "****"
        }
    }
    
    @objc func tapAction() {
        if TYUserInfoHelper.userIsLogedIn() {
            inComeClosure?(.drawMoney)
        } else {
            inComeClosure?(.login)
        }
    }
    
    @objc func bottomTapAction() {
        if TYUserInfoHelper.userIsLogedIn() {
            inComeClosure?(.drawShell)
        } else {
            inComeClosure?(.login)
        }
    }
    
    /// 去兑换
    @objc func goConvert() {
        if TYUserInfoHelper.userIsLogedIn() {
            inComeClosure?(.drawShell)
        } else {
            inComeClosure?(.login)
        }
    }
    
    /// 去赚贝壳
    @objc func goMakeBeke() {
        if TYUserInfoHelper.userIsLogedIn() {
            inComeClosure?(.goGame)
        } else {
            inComeClosure?(.login)
        }
    }
}
