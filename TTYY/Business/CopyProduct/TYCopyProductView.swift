//
//  TYCopyProductView.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/20.
//

import UIKit
import BaseModule

class TYCopyProductView: UIView {
    private var contentView = UIView()
    private var tipContentView = UIView()
    
    var btnClickClosure: ((Int, String?)->Void)?
    var productInfo: TYProductInfoModel?
    private var tkl = ""
    
    func createSubview(_ model: TYProductInfoModel?, tkl: String) {
        productInfo = model
        backgroundColor = Color_HexA(0x000000, alpha: 0.6)
        self.tkl = tkl
        addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Screen_IPadMultiply(10)
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(309), height: Screen_IPadMultiply(262)))
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(tipContentView)
        let tipBounds = CGRect(x: 0, y: 0, width: Screen_IPadMultiply(309), height: Screen_IPadMultiply(70))
        tipContentView.bounds = tipBounds
        let layer = CAGradientLayer.init()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.colors = [Color_Hex(0xFD5660).cgColor, Color_Hex(0xEB2B36).cgColor]
        layer.frame = tipBounds
        tipContentView.layer.addSublayer(layer)
        tipContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(70))
        }
        
        let tipLabel = UILabel()
        tipLabel.text = "已为您找到".yjs_translateStr()
        tipLabel.font = Font_Semibold_IPadMul(18)
        tipLabel.textColor = .white
        tipLabel.textAlignment = .center
        tipContentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "ty_product_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        tipContentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(38), height: Screen_IPadMultiply(38)))
        }
        
        if let productInfo = model {
            createProductInfoView(model: productInfo)
        }
        else {
            createProductURLView(tkl: tkl)
        }
    }
    
    private func createProductInfoView(model: TYProductInfoModel) {
        let bgView = UIView()
        contentView.addSubview(bgView)
        let goodsImgV = UIImageView()
        contentView.addSubview(goodsImgV)
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tipContentView.snp.bottom)
        }
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(productClick)))
        goodsImgV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(14))
            make.top.equalTo(tipContentView.snp.bottom).offset(Screen_IPadMultiply(22))
            make.width.height.equalTo(Screen_IPadMultiply(84))
        }
        if let url = URL(string: model.goodsImgUrl) {
            goodsImgV.sd_setImage(with: url)
        }
        goodsImgV.layer.cornerRadius = 6
        goodsImgV.clipsToBounds = true
        let typeIcon = UIImageView()
        contentView.addSubview(typeIcon)
        typeIcon.snp.makeConstraints { make in
            make.left.equalTo(goodsImgV.snp.right).offset(Screen_IPadMultiply(9))
            make.top.equalTo(goodsImgV.snp.top)
            make.width.height.equalTo(Screen_IPadMultiply(17))
        }
        if let url = URL(string: model.sTypeIcon) {
            typeIcon.sd_setImage(with: url)
        }
        
        let titleLb = UILabel()
        titleLb.font = Font_Medium_IPadMul(14)
        titleLb.textColor = Color_Hex(0x262626)
        titleLb.text = model.goodsTitle
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(typeIcon.snp.right).offset(Screen_IPadMultiply(3))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-16))
            make.centerY.equalTo(typeIcon)
        }
        
        if model.saveMoney > 0 {
            let saveStr = String(format: "预计赚￥%.02f", model.saveMoney)
            let strWidth = (saveStr as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: Screen_IPadMultiply(18)), options: .truncatesLastVisibleLine, attributes: [:], context: nil).size.width + 20
            let saveView = UIView()
            contentView.addSubview(saveView)
            let saveBounds = CGRect(x: 0, y: 0, width: Screen_IPadMultiply(strWidth), height: Screen_IPadMultiply(18))
            saveView.bounds = saveBounds
            saveView.roundCorners([.topLeft, .topRight, .bottomRight], radius: Screen_IPadMultiply(9))
            let layer = CAGradientLayer.init()
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.colors = [Color_Hex(0xFE3E49).cgColor, Color_Hex(0xEE212D).cgColor]
            layer.frame = saveBounds
            saveView.layer.addSublayer(layer)

            saveView.snp.makeConstraints { make in
                make.left.equalTo(goodsImgV.snp.right).offset(Screen_IPadMultiply(9))
                make.top.equalTo(typeIcon.snp.bottom).offset(Screen_IPadMultiply(10))
                make.height.equalTo(Screen_IPadMultiply(18))
                make.width.equalTo(Screen_IPadMultiply(strWidth))
            }
            
            let tipLabel = UILabel()
            tipLabel.textColor = .white
            tipLabel.textAlignment = .center
            saveView.addSubview(tipLabel)
            tipLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            let attStr = NSMutableAttributedString(string: saveStr)
            attStr.addAttributes([.font: Font_Medium_IPadMul(10)], range: NSRange(location: 0, length: 4))
            attStr.addAttributes([.font: Font_Medium_IPadMul(14)], range: NSRange(location: 4, length: saveStr.count - 4))
            tipLabel.attributedText = attStr
        }
        
        let priceLabel = UILabel()
        priceLabel.textColor = Color_Hex(0xE11521)
        priceLabel.textAlignment = .left
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(goodsImgV.snp.bottom)
            make.left.equalTo(typeIcon)
        }
        let priceStr = String(format: "到手约￥%.02f", model.price)
        let priceAttStr = NSMutableAttributedString(string: priceStr)
        priceAttStr.addAttributes([.font: Font_System_IPadMul(10)], range: NSRange(location: 0, length: 3))
        priceAttStr.addAttributes([.font: Font_Medium_IPadMul(12)], range: NSRange(location: 3, length: 1))
        priceAttStr.addAttributes([.font: Font_Medium_IPadMul(20)], range: NSRange(location: 4, length: priceStr.count - 4))
        priceLabel.attributedText = priceAttStr
        
        let originalPriceLb = UILabel()
        originalPriceLb.textColor = Color_Hex(0x999999)
        contentView.addSubview(originalPriceLb)
        originalPriceLb.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(Screen_IPadMultiply(3))
            make.bottom.equalTo(priceLabel)
        }
        
        let originalPriceStr = String(format: "￥%.02f", model.originalprice)
        let originalPriceAttStr = NSMutableAttributedString(string: originalPriceStr)
        originalPriceAttStr.addAttributes([.font: Font_System_IPadMul(12), .strikethroughStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 0, length: originalPriceStr.count))
        originalPriceLb.attributedText = originalPriceAttStr
        
        let merchantTitleLabel = UILabel()
        merchantTitleLabel.text = model.merchantTitle
        merchantTitleLabel.textAlignment = .center
        merchantTitleLabel.textColor = Color_Hex(0x999999)
        merchantTitleLabel.font = Font_System_IPadMul(12)
        contentView.addSubview(merchantTitleLabel)
        merchantTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(14))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-14))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-16))
            make.height.equalTo(Screen_IPadMultiply(17))
        }
    }
    
    private func createProductURLView(tkl: String) {
        let urlLb = UILabel()
        urlLb.text = tkl
        urlLb.textColor = Color_Hex(0x262626)
        urlLb.font = Font_Medium_IPadMul(14)
        urlLb.numberOfLines = 2
        contentView.addSubview(urlLb)
        urlLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(24))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-8))
            make.top.equalTo(tipContentView.snp.bottom).offset(Screen_IPadMultiply(44))
        }
        
        let oneBtn = UIButton()
        var btnImage = "ty_jd_icon"
        var btnTitle = ""
        var btnTag = 0
        if tkl.contains("item.m.jd.com") {
            btnImage = "ty_jd_icon"
            btnTitle = "搜京东"
            btnTag = 1
        } else if tkl.contains("mobile.yangkeduo.com") {
            btnImage = "ty_pdd_icon"
            btnTitle = "搜拼多多"
            btnTag = 3
        } else if tkl.contains("m.tb.cn") {
            btnImage = "ty_taobao_icon"
            btnTitle = "搜淘宝/天猫"
            btnTag = 2
        }
        oneBtn.setTitle(btnTitle, for: .normal)
        oneBtn.setImage(UIImage(named: btnImage), for: .normal)
        oneBtn.setTitleColor(.white, for: .normal)
        oneBtn.titleLabel?.font = Font_System_IPadMul(14)
        oneBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        oneBtn.layer.cornerRadius = Screen_IPadMultiply(8)
        oneBtn.layer.masksToBounds = true
        oneBtn.tag = btnTag
        oneBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        oneBtn.addTarget(self, action: #selector(oneBtnClick(btn:)), for: .touchUpInside)
        contentView.addSubview(oneBtn)
        oneBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-25))
            make.height.equalTo(Screen_IPadMultiply(40))
            make.width.equalTo(Screen_IPadMultiply(230))
            make.centerX.equalToSuperview()
        }
    }
}

private extension TYCopyProductView {
    @objc func closeBtnClick() {
        removeFromSuperview()
        UIPasteboard.general.string = ""
    }
    
    @objc func leftBtnClick() {
        // 全网比较
        btnClickClosure?(4, nil)
        closeBtnClick()
    }
    
    @objc func productClick() {
        closeBtnClick()
        let goodsId = productInfo?.goodsId ?? ""
        if let productInfo = productInfo, productInfo.sType == "pdd" {
            if TYUserInfoHelper.userIsLogedIn() == false {
                UIApplication.getCurrentVC()?.navigationController?.pushViewController(TYLoginVC(), animated: true)
                return
            }
            if productInfo.saveMoney > 0 {
                TYCashEnvelopePromptView.show(productModel: productInfo, type: 4, tkl: tkl)
            } else {
                TYCopyProductHelper.goPdd(productInfo.goodsId)
            }
        } else {
            btnClickClosure?(4, goodsId)
        }
    }
    
    @objc func oneBtnClick(btn: UIButton) {
        btnClickClosure?(btn.tag, nil)
        closeBtnClick()
    }
}
