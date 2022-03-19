//
//  TYMineDetailCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//

import UIKit
import BaseModule

enum DetailActionType {
    case order      // 我的订单
    case detail     // 收益明细
    case collect    // 有余收藏
    case partner    // 合伙人
    case login      // 登录
}

class TYMineDetailCell: UITableViewCell {
    
    var detailClosure: ((DetailActionType)->Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadPartnerData () {
        let joinLabel = viewWithTag(1000) as? UILabel
        if TYUserInfoHelper.getUserType() == 1 {
            joinLabel?.isHidden = false
            if joinLabel?.layer.animation(forKey: "transform") == nil {
                joinLabel?.pulse2(withDuration: 0.8)
            }
        }
        else {
            joinLabel?.isHidden = true
        }
    }
}

private extension TYMineDetailCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        selectionStyle = .none
        let bgImgV = UIImageView(image: UIImage(named: "product_bg"))
        bgImgV.isUserInteractionEnabled = true
        contentView.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-10))
            make.top.bottom.equalToSuperview()
        }
        
        let btnW = (Screen_Width - Screen_IPadMultiply(20)) / 4.0
        
        let orderBtn = TYMineBtn()
        orderBtn.titleLabel?.textAlignment = .center
        orderBtn.setTitle("我的订单", for: .normal)
        orderBtn.setTitleColor(Color_Hex(0x595959), for: .normal)
        orderBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        orderBtn.setImage(UIImage(named: "mine_order_list"), for: .normal)
        orderBtn.addTarget(self, action: #selector(orderBtnClick), for: .touchUpInside)
        bgImgV.addSubview(orderBtn)
        orderBtn.snp.makeConstraints { make in
            make.left.bottom.top.equalToSuperview()
            make.width.equalTo(btnW)
        }
        
        let moneyDetailBtn = TYMineBtn()
        moneyDetailBtn.titleLabel?.textAlignment = .center
        moneyDetailBtn.setTitle("收益明细", for: .normal)
        moneyDetailBtn.setTitleColor(Color_Hex(0x595959), for: .normal)
        moneyDetailBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        moneyDetailBtn.setImage(UIImage(named: "mine_money_detail"), for: .normal)
        moneyDetailBtn.addTarget(self, action: #selector(moneyDetailBtnClick), for: .touchUpInside)
        bgImgV.addSubview(moneyDetailBtn)
        moneyDetailBtn.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.left.equalTo(orderBtn.snp.right)
            make.width.equalTo(btnW)
        }
        
        let partnerBtn = TYMineBtn()
        partnerBtn.titleLabel?.textAlignment = .center
        partnerBtn.setTitle("合伙人", for: .normal)
        partnerBtn.setTitleColor(Color_Hex(0x595959), for: .normal)
        partnerBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        partnerBtn.setImage(UIImage(named: "mine_partner_tab"), for: .normal)
        partnerBtn.addTarget(self, action: #selector(partnerBtnClick), for: .touchUpInside)
        bgImgV.addSubview(partnerBtn)
        partnerBtn.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.left.equalTo(moneyDetailBtn.snp.right)
            make.width.equalTo(btnW)
        }
        var joinLabel = viewWithTag(1000) as? UILabel
        if joinLabel == nil {
            joinLabel = UILabel()
            joinLabel?.tag = 1000
            joinLabel?.text = "立即加入"
            joinLabel?.textColor = .white
            joinLabel?.backgroundColor = UIColor.init(rgbHex: 0xF7313D)
            joinLabel?.font = Font_Medium_IPadMul(10)
            joinLabel?.textAlignment = .center
            joinLabel?.layer.masksToBounds = true
            bgImgV.addSubview(joinLabel!)
            joinLabel?.frame = CGRect(x: 2 * btnW + (btnW - Screen_IPadMultiply(48)) / 2.0 + Screen_IPadMultiply(28), y: Screen_IPadMultiply(32) / 2.0, width: Screen_IPadMultiply(49), height: Screen_IPadMultiply(18))
            let corner = CornerRadius(topLeft: Screen_IPadMultiply(18) / 2, topRight: Screen_IPadMultiply(18) / 2, bottomLeft: Screen_IPadMultiply(2), bottomRight: Screen_IPadMultiply(18) / 2)
            joinLabel?.addCorner(cornerRadius: corner, borderColor: .white, borderWidth: 1)
            joinLabel?.setAnchorPoint(CGPoint(x: 0, y: 1))
        }
        
        let recordBtn = TYMineBtn()
        recordBtn.titleLabel?.textAlignment = .center
        recordBtn.setTitle("有余收藏", for: .normal)
        recordBtn.setTitleColor(Color_Hex(0x595959), for: .normal)
        recordBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        recordBtn.setImage(UIImage(named: "mine_look_note"), for: .normal)
        recordBtn.addTarget(self, action: #selector(recordDetailClick), for: .touchUpInside)
        bgImgV.addSubview(recordBtn)
        recordBtn.snp.makeConstraints { make in
            make.bottom.top.right.equalToSuperview()
            make.width.equalTo(btnW)
        }
    }
    
    @objc func orderBtnClick() {
        if TYUserInfoHelper.userIsLogedIn() {
            detailClosure?(.order)
        } else {
            detailClosure?(.login)
        }
    }
    
    @objc func partnerBtnClick() {
        if TYUserInfoHelper.userIsLogedIn() {
            detailClosure?(.partner)
        } else {
            detailClosure?(.login)
        }
    }
    
    @objc func moneyDetailBtnClick() {
        if TYUserInfoHelper.userIsLogedIn() {
            detailClosure?(.detail)
        } else {
            detailClosure?(.login)
        }
    }
    
    @objc func recordDetailClick() {
        if TYUserInfoHelper.userIsLogedIn() {
            detailClosure?(.collect)
        } else {
            detailClosure?(.login)
        }
    }
}
