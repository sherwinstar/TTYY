//
//  TYExplosiveProductCell.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/4.
//

import UIKit
import BaseModule

class TYExplosiveProductCell: UITableViewCell {
    
    var sharedProductClosure: ((String)->Void)?
    
    /// 平台图标
    private var platformImgV = UIImageView()
    /// 店铺名称
    private var shopNameLb = UILabel()
    /// 多少人付款
    private var buysLb = UILabel()
    /// 商品图片
    private var productImgV = UIImageView()
    /// 商品名称
    private var productNameLb = UILabel()
    /// 券
    private var couponTipLb = UILabel()
    /// 优惠券金额
    private var couponLb = UILabel()
    /// 预计赚
    private var makeMoneyLb = UILabel()
    /// 价格
    private var priceLb = UILabel()
    /// 复制文字
//    private var copyBtn = UIButton()
//    /// 分享图片
//    private var shareBtn = UIButton()
//    /// 显示已推送或者未推送，还有隐藏
//    private var stateLb = UILabel()
//    /// 立即购买
//    private var buyBtn = UIButton()
    
    private var productModel: TYShopProductModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ model: TYShopProductModel, bottomBtnState: Bool) {
        productModel = model
        if let platformURL = URL(string: model.sTypeIcon) {
            platformImgV.sd_setImage(with: platformURL)
        }
        shopNameLb.text = model.merchantTitle
        buysLb.text = model.payUser + "人已下单"
        
        var img = model.goodsImgUrl
        if !img.hasPrefix("http") {
            img = "http:" + img
        }
        if let imgURL = URL(string: img) {
            productImgV.sd_setImage(with: imgURL)
        }
        productNameLb.text = model.goodsTitle
        
        if model.coupons > 0 {
            couponTipLb.isHidden = false
            couponLb.isHidden = false
            var couponStr = ""
            let money = modf(model.coupons)
            if money.1 != 0 {
                couponStr = String(format: "￥%.02f ", model.coupons)
            } else {
                couponStr = "￥\(Int(model.coupons)) "
            }
            if !couponStr.isBlank {
                let couponAtt = NSMutableAttributedString(string: couponStr)
                couponAtt.addAttributes([.font: Font_Medium_IPadMul(10), .foregroundColor: UIColor.white], range: NSRange(location: 0, length: 1))
                couponAtt.addAttributes([.font: Font_Medium_IPadMul(13), .foregroundColor: UIColor.white], range: NSRange(location: 1, length: couponStr.count - 1))
                couponLb.attributedText = couponAtt
            }
            
            makeMoneyLb.snp.remakeConstraints { make in
                make.left.equalTo(couponLb.snp.right).offset(Screen_IPadMultiply(4))
                make.bottom.top.equalTo(couponLb)
            }
        } else {
            couponTipLb.isHidden = true
            couponLb.isHidden = true
            makeMoneyLb.snp.remakeConstraints { make in
                make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(3))
                make.left.equalTo(productNameLb)
                make.height.equalTo(Screen_IPadMultiply(18))
            }
        }
        let moneyStr = String(format: " 返红包￥%.02f ", model.saveMoney)
        let moneyAtt = NSMutableAttributedString(string: moneyStr)
        moneyAtt.addAttributes([.font: Font_Medium_IPadMul(10), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 0, length: 5))
        moneyAtt.addAttributes([.font: Font_Medium_IPadMul(13), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 5, length: moneyStr.count - 5))
        makeMoneyLb.attributedText = moneyAtt
        
        let priceStr = String(format: "到手约 ￥%.02f", model.price)
        let originalpriceStr = String(format: " ￥%.02f", model.originalprice)
        let totalStr = priceStr + originalpriceStr
        let att = NSMutableAttributedString(string: totalStr)
        att.addAttributes([.font:Font_System_IPadMul(12), .foregroundColor: Color_Hex(0x999999)], range: NSRange(location: 0, length: 3))
        att.addAttributes([.font: Font_Medium_IPadMul(12), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 4, length: 1))
        att.addAttributes([.font: Font_Medium_IPadMul(20), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 5, length: priceStr.count - 5))
        att.addAttributes([.font: Font_System_IPadMul(12), .foregroundColor: Color_Hex(0x999999)], range: NSRange(location: priceStr.count, length: originalpriceStr.count))
        att.addAttributes([.strikethroughStyle: NSUnderlineStyle.single.rawValue,.baselineOffset : 0], range: NSRange(location: priceStr.count, length: originalpriceStr.count))
        priceLb.attributedText = att
        
//        refreshBtnState(state: bottomBtnState)
    }
}

private extension TYExplosiveProductCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        let bgImgV = UIImageView(image: UIImage(named: "product_bg"))
        contentView.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-10))
        }
        
        contentView.addSubview(platformImgV)
        platformImgV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(30))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.width.height.equalTo(Screen_IPadMultiply(17))
        }
        
        contentView.addSubview(shopNameLb)
        shopNameLb.font = Font_System_IPadMul(12)
        shopNameLb.textColor = Color_Hex(0x999999)
        shopNameLb.snp.makeConstraints { make in
            make.centerY.equalTo(platformImgV)
            make.left.equalTo(platformImgV.snp.right).offset(Screen_IPadMultiply(6))
        }
        
        contentView.addSubview(buysLb)
        buysLb.textColor = Color_Hex(0x595959)
        buysLb.font = Font_System_IPadMul(12)
        buysLb.textAlignment = .right
        buysLb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-34))
            make.centerY.equalTo(platformImgV)
        }
        
        contentView.addSubview(productImgV)
        productImgV.layer.cornerRadius = Screen_IPadMultiply(6)
        productImgV.layer.masksToBounds = true
        productImgV.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(104))
            make.top.equalTo(platformImgV.snp.bottom).offset(Screen_IPadMultiply(12))
            make.left.equalTo(platformImgV)
        }
        
        contentView.addSubview(productNameLb)
        productNameLb.textColor = Color_Hex(0x262626)
        productNameLb.numberOfLines = 2
        productNameLb.font = Font_Medium_IPadMul(14)
        productNameLb.snp.makeConstraints { make in
            make.left.equalTo(productImgV.snp.right).offset(Screen_IPadMultiply(10))
            make.top.equalTo(productImgV)
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-34))
        }
        
        contentView.addSubview(couponTipLb)
        couponTipLb.text = "券"
        couponTipLb.textColor = .white
        couponTipLb.layer.cornerRadius = Screen_IPadMultiply(3)
        couponTipLb.layer.masksToBounds = true
        couponTipLb.font = Font_Medium_IPadMul(10)
        couponTipLb.backgroundColor = Color_Hex(0xF7313D)
        couponTipLb.textAlignment = .center
        couponTipLb.snp.makeConstraints { make in
            make.left.equalTo(productNameLb)
            make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(8))
            make.width.equalTo(Screen_IPadMultiply(16))
            make.height.equalTo(Screen_IPadMultiply(18))
        }
        
        contentView.addSubview(couponLb)
        couponLb.textColor = .white
        couponLb.layer.cornerRadius = Screen_IPadMultiply(3)
        couponLb.layer.masksToBounds = true
        couponLb.font = Font_Medium_IPadMul(10)
        couponLb.backgroundColor = Color_Hex(0xF7313D)
        couponLb.textAlignment = .center
        couponLb.snp.makeConstraints { make in
            make.top.bottom.equalTo(couponTipLb)
            make.left.equalTo(couponTipLb.snp.right)
        }
        
        contentView.addSubview(makeMoneyLb)
        makeMoneyLb.backgroundColor = Color_Hex(0xFBE053)
        makeMoneyLb.layer.cornerRadius = Screen_IPadMultiply(3)
        makeMoneyLb.layer.masksToBounds = true
        makeMoneyLb.textColor = Color_Hex(0x724212)
        makeMoneyLb.textAlignment = .center
        makeMoneyLb.font = Font_Medium_IPadMul(10)
        makeMoneyLb.snp.makeConstraints { make in
            make.left.equalTo(couponLb.snp.right).offset(Screen_IPadMultiply(4))
            make.bottom.top.equalTo(couponTipLb)
            
        }
        
        contentView.addSubview(priceLb)
        priceLb.snp.makeConstraints { make in
            make.left.equalTo(productNameLb)
            make.bottom.equalTo(productImgV.snp.bottom).offset(Screen_IPadMultiply(-8))
        }
        
//        contentView.addSubview(copyBtn)
//        refreshBtn(copyBtn, title: "复制文字")
//        copyBtn.snp.makeConstraints { make in
//            make.width.equalTo(Screen_IPadMultiply(55))
//            make.height.equalTo(Screen_IPadMultiply(20))
//            make.left.equalTo(productImgV)
//            make.top.equalTo(productImgV.snp.bottom).offset(Screen_IPadMultiply(18))
//        }
//
//        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        
//        contentView.addSubview(shareBtn)
//        refreshBtn(shareBtn, title: "分享图片")
//        shareBtn.snp.makeConstraints { make in
//            make.width.height.equalTo(copyBtn)
//            make.centerY.equalTo(copyBtn)
//            make.left.equalTo(copyBtn.snp.right).offset(Screen_IPadMultiply(15))
//        }
//        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        
//        contentView.addSubview(stateLb)
//        stateLb.text = "未推送"
//        stateLb.backgroundColor = Color_Hex(0xEFEFEF)
//        stateLb.layer.cornerRadius = Screen_IPadMultiply(2)
//        stateLb.layer.masksToBounds = true
//        stateLb.font = Font_System_IPadMul(10)
//        stateLb.textColor = Color_Hex(0x999999)
//        stateLb.textAlignment = .center
//        stateLb.snp.makeConstraints { make in
//            make.left.equalTo(shareBtn.snp.right).offset(Screen_IPadMultiply(15))
//            make.centerY.equalTo(copyBtn)
//            make.width.equalTo(Screen_IPadMultiply(38))
//            make.height.equalTo(Screen_IPadMultiply(16))
//        }
        
//        contentView.addSubview(buyBtn)
//        buyBtn.isEnabled = false
//        buyBtn.layer.borderWidth = 1
//        buyBtn.layer.borderColor = Color_Hex(0xE11521).cgColor
//        buyBtn.layer.cornerRadius = Screen_IPadMultiply(6)
//        buyBtn.layer.masksToBounds = true
//        buyBtn.setTitle("立即购买", for: .normal)
//        buyBtn.setTitleColor(Color_Hex(0xE11521), for: .normal)
//        buyBtn.titleLabel?.font = Font_System_IPadMul(12)
//        buyBtn.snp.makeConstraints { make in
//            make.width.equalTo(Screen_IPadMultiply(80))
//            make.height.equalTo(Screen_IPadMultiply(28))
//            make.right.equalToSuperview().offset(Screen_IPadMultiply(-34))
//            make.centerY.equalTo(copyBtn)
//        }
        
    }
    
//    func refreshBtn(_ btn: UIButton, title: String) {
//        btn.setTitleColor(Color_Hex(0x262626), for: .normal)
//        btn.titleLabel?.font = Font_System_IPadMul(12)
//        let att = NSMutableAttributedString(string: title)
//        att.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 0, length: title.count))
//        btn.setAttributedTitle(att, for: .normal)
//    }
    
//    func refreshBtnState(state: Bool) {
//        if productModel?.sType == "taobao" {
//            copyBtn.isHidden = true
//            shareBtn.isHidden = true
//            stateLb.isHidden = true
//            return
//        }
//        let type = TYUserInfoHelper.getUserType()
//        if type == 2 {
//            // 合伙人
//            copyBtn.isHidden = false
//            shareBtn.isHidden = false
//            stateLb.isHidden = false
//        } else {
//            copyBtn.isHidden = true
//            shareBtn.isHidden = true
//            stateLb.isHidden = true
//        }
//        if state == false {
//            stateLb.isHidden = true
//        }
//    }
    
//    @objc func copyAction() {
//        if let id = productModel?.goodsId, !id.isBlank {
//            stateLb.isHidden = true
//            sharedProductClosure?(id)
//        }
//        if productModel?.sType == "pdd" {
//            TYShopService.requestPDDTkl(goodsId: productModel?.goodsId ?? "") { [weak self] msg in
//                self?.showToast(msg: msg)
//            }
//        } else if productModel?.sType == "jd" {
//            TYShopService.requestJDTkl(goodsId: productModel?.goodsId ?? "") { [weak self] msg in
//                self?.showToast(msg: msg)
//            }
//        }
//    }
    
//    @objc func shareAction() {
//        if let id = productModel?.goodsId, !id.isBlank {
//            stateLb.isHidden = true
//            sharedProductClosure?(id)
//        }
//        if let productImg = productModel?.goodsImgUrl, !productImg.isBlank {
//            TYShareManager.shared.shareImage(url: productImg)
//        }
//    }
}

