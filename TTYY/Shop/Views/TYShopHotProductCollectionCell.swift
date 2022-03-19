//
//  TYShopHotProductCollectionCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

class TYShopHotProductCollectionCell: UICollectionViewCell {
    
    /// 图片
    private var productImgV = UIImageView()
    /// 商品名称
    private var productNameLb = UILabel()
    /// 优惠券金额
    private var couponLb = UILabel()
    /// 预计赚
    private var makeMoneyLb = UILabel()
    /// 价格
    private var priceLb = UILabel()
    /// 复制文字
    private var copyBtn = UIButton()
    /// 分享图片
    private var shareBtn = UIButton()
    
    private var productModel: TYShopProductModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(model: TYShopProductModel) {
        productModel = model
        if let imgURL = URL(string: model.goodsImgUrl) {
            productImgV.sd_setImage(with: imgURL)
        }
        productNameLb.text = model.goodsTitle
        
        if model.coupons > 0 {
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
            couponLb.isHidden = true
            makeMoneyLb.snp.remakeConstraints { make in
                make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(3))
                make.left.equalTo(productImgV)
                make.height.equalTo(Screen_IPadMultiply(18))
            }
        }
        let moneyStr = String(format: " 返红包￥%.02f ", model.saveMoney)
        let moneyAtt = NSMutableAttributedString(string: moneyStr)
        moneyAtt.addAttributes([.font: Font_Medium_IPadMul(10), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 0, length: 5))
        moneyAtt.addAttributes([.font: Font_Medium_IPadMul(13), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 5, length: moneyStr.count - 5))
        makeMoneyLb.attributedText = moneyAtt
        let priceStr = String(format: "到手约 ￥%.02f", model.price)
        let att = NSMutableAttributedString(string: priceStr)
        att.addAttributes([.font:Font_System_IPadMul(10), .foregroundColor: Color_Hex(0x999999)], range: NSRange(location: 0, length: 3))
        att.addAttributes([.font: Font_Medium_IPadMul(12), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 4, length: 1))
        att.addAttributes([.font: Font_Medium_IPadMul(16), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 5, length: priceStr.count - 5))
        priceLb.attributedText = att
        
        refreshBtnState()
    }
}

private extension TYShopHotProductCollectionCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        let bgImgV = UIImageView(image: UIImage(named: "product_bg"))
        contentView.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(productImgV)
        productImgV.layer.cornerRadius = Screen_IPadMultiply(6)
        productImgV.layer.masksToBounds = true
        productImgV.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(123))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_IPadMultiply(13))
        }
        
        contentView.addSubview(productNameLb)
        productNameLb.textColor = Color_Hex(0x262626)
        productNameLb.textAlignment = .left
        productNameLb.font = Font_Medium_IPadMul(12)
        productNameLb.snp.makeConstraints { make in
            make.left.right.equalTo(productImgV)
            make.top.equalTo(productImgV.snp.bottom).offset(Screen_IPadMultiply(5))
        }
        
        contentView.addSubview(couponLb)
        couponLb.textColor = .white
        couponLb.layer.cornerRadius = Screen_IPadMultiply(3)
        couponLb.layer.masksToBounds = true
        couponLb.font = Font_Medium_IPadMul(10)
        couponLb.backgroundColor = Color_Hex(0xF7313D)
        couponLb.textAlignment = .center
        couponLb.snp.makeConstraints { make in
            make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(3))
            make.left.equalTo(productImgV)
            make.height.equalTo(Screen_IPadMultiply(18))
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
            make.bottom.top.equalTo(couponLb)
        }
        
        contentView.addSubview(priceLb)
        priceLb.snp.makeConstraints { make in
            make.left.equalTo(productNameLb)
            make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(28))
        }
        priceLb.text = "到手约￥120.00"
        
        contentView.addSubview(copyBtn)
        refreshBtn(copyBtn, title: "复制文字")
        copyBtn.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(58))
            make.height.equalTo(Screen_IPadMultiply(28))
            make.left.equalTo(productNameLb)
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-15))
        }
        
        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        
        contentView.addSubview(shareBtn)
        refreshBtn(shareBtn, title: "分享图片")
        shareBtn.snp.makeConstraints { make in
            make.width.height.equalTo(copyBtn)
            make.right.equalTo(productImgV)
            make.centerY.equalTo(copyBtn)
        }
        
        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
    }
    
    /// 判断按钮是否显示
    func refreshBtnState() {
        if productModel?.sType == "taobao" {
            // 淘宝没有这部分功能
            copyBtn.isHidden = true
            shareBtn.isHidden = true
            return
        }
        let type = TYUserInfoHelper.getUserType()
        if type == 2 {
            // 合伙人
            copyBtn.isHidden = false
            shareBtn.isHidden = false
        } else {
            copyBtn.isHidden = true
            shareBtn.isHidden = true
        }
    }
    
    func refreshBtn(_ btn: UIButton, title: String) {
        btn.layer.borderWidth = 1
        btn.layer.borderColor = Color_Hex(0xBEBEBE).cgColor
        btn.layer.cornerRadius = Screen_IPadMultiply(6)
        btn.layer.masksToBounds = true
        btn.setTitleColor(Color_Hex(0x262626), for: .normal)
        btn.titleLabel?.font = Font_System_IPadMul(12)
        btn.setTitle(title, for: .normal)
    }
    
    @objc func copyAction() {
        if productModel?.sType == "pdd" {
            TYShopService.requestPDDTkl(goodsId: productModel?.goodsId ?? "") { [weak self] msg in
                self?.showToast(msg: msg)
            }
        } else if productModel?.sType == "jd" {
            TYShopService.requestJDTkl(goodsId: productModel?.goodsId ?? "") { [weak self] msg in
                self?.showToast(msg: msg)
            }
        }
    }
    
    @objc func shareAction() {
        if let productImg = productModel?.goodsImgUrl, !productImg.isBlank {
            TYShareManager.shared.shareImage(url: productImg)
        }
    }
}
