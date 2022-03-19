//
//  TYOrderCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//

import UIKit
import BaseModule

class TYOrderCell: UITableViewCell {
    
    private var orderInfo: TYOrderInfoModel?
    
    /// 商品平台图片
    private var typeImgV = UIImageView()
    /// 订单号
    private var orderIdLb = UILabel()
    /// 商品图片
    private var productImgV = UIImageView()
    /// 商品名称
    private var productNameLb = UILabel()
    /// 商品价格
    private var productPriceLb = UILabel()
    /// 已失效
    private var statusNoneLb = UILabel()
    /// 预计赚图片
    private var moneyImgV = UIImageView()
    /// 预计赚金额
    private var moneyNumLb = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(orderInfo: TYOrderInfoModel) {
        self.orderInfo = orderInfo
        let imgName = getTypeImageName(type: orderInfo.sType)
        typeImgV.image = UIImage(named: imgName)
        orderIdLb.text = "订单号 " + orderInfo.orderID
        var img = orderInfo.goodsImgUrl
        if !img.hasPrefix("http") {
            img = "http:" + img
        }
        if let imgULR = URL(string: img) {
            productImgV.sd_setImage(with: imgULR)
        }
        
        let price = String(format: "￥%.02f", orderInfo.money)
        handlePriceString(orderInfo.rebateStatus, price: price)
        var productNameColor: UIColor
        var productFrom: String = ""
        var productFromW: CGFloat = 0
        if orderInfo.rebateStatus == "3" {
            // 已失效
            productNameColor = Color_Hex(0x999999)
            statusNoneLb.isHidden = false
            moneyImgV.isHidden = true
            if orderInfo.userId != TYUserInfoHelper.getUserId() {
                // 粉丝订单
                productFrom = "order_fans_icon"
                productFromW = Screen_IPadMultiply(28)
            } else if orderInfo.orderPromoteType == 2 {
                // 新人免单
                productFrom = "order_newuser_icon"
                productFromW = Screen_IPadMultiply(48)
            } else {
                productFrom = ""
            }
        } else {
            productNameColor = Color_Hex(0x262626)
            statusNoneLb.isHidden = true
            moneyImgV.isHidden = false
            var imgW: CGFloat = 0
            if orderInfo.rebateStatus == "1" {
                moneyImgV.image = UIImage(named: "order_plan_money")
                imgW = 43
            } else if orderInfo.rebateStatus == "2" {
                moneyImgV.image = UIImage(named: "order_make_money")
                imgW = 24
            }
            var moneyStr = ""
            if orderInfo.userId != TYUserInfoHelper.getUserId() {
                // 粉丝订单
                productFrom = "order_fans_icon"
                moneyStr = String(format: "￥%.02f", orderInfo.promoterMoney)
                productFromW = Screen_IPadMultiply(28)
            } else if orderInfo.orderPromoteType == 2 {
                moneyStr = String(format: "￥%.02f", orderInfo.money)
                productFrom = "order_newuser_icon"
                productFromW = Screen_IPadMultiply(48)
            } else {
                moneyStr = String(format: "￥%.02f", orderInfo.rebateMoney)
                productFrom = ""
            }
            let moneyW = moneyStr.yjs_stringSize(fontSize: 14, size: CGSize(width: 1000, height: Screen_IPadMultiply(18))).size.width
            moneyImgV.snp.remakeConstraints { make in
                make.left.equalTo(productNameLb)
                make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(8))
                make.width.equalTo(Screen_IPadMultiply(imgW + moneyW))
                make.height.equalTo(Screen_IPadMultiply(18))
            }
            let moneyAtt = NSMutableAttributedString(string: moneyStr)
            moneyAtt.addAttributes([.font: Font_Medium_IPadMul(10), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 0, length: 1))
            moneyAtt.addAttributes([.font: Font_Medium_IPadMul(14), .foregroundColor: Color_Hex(0x724212)], range: NSRange(location: 1, length: moneyStr.count - 1))
            moneyNumLb.attributedText = moneyAtt
            moneyNumLb.snp.remakeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(Screen_IPadMultiply(moneyW))
            }
        }
        
        // 设置商品名称
        let productNameAtt = NSMutableAttributedString(string: "")
        if !productFrom.isBlank {
            let productNameMent = NSTextAttachment()
            productNameMent.image = UIImage(named: productFrom)
            productNameMent.bounds = CGRect(x: 0, y: -4, width: productFromW, height: Screen_IPadMultiply(17))
            let productNameImgAtt = NSAttributedString(attachment: productNameMent)
            productNameAtt.append(productNameImgAtt)
        }
        let productName = orderInfo.goodsTitle
        let nameAtt = NSMutableAttributedString(string: " " + productName)
        nameAtt.addAttributes([.font:  Font_Medium_IPadMul(14), .foregroundColor: productNameColor], range: NSRange(location: 0, length: productName.count + 1))
        productNameAtt.append(nameAtt)
        productNameLb.attributedText = productNameAtt
    }
}

private extension TYOrderCell {
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
        
        bgImgV.addSubview(typeImgV)
        typeImgV.image = UIImage(named: "order_pdd_icon")
        typeImgV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(18))
            make.width.height.equalTo(Screen_IPadMultiply(17))
        }
        
        bgImgV.addSubview(orderIdLb)
        orderIdLb.textColor = Color_Hex(0x595959)
        orderIdLb.font = Font_System_IPadMul(12)
        orderIdLb.snp.makeConstraints { make in
            make.left.equalTo(typeImgV.snp.right).offset(Screen_IPadMultiply(6))
            make.centerY.equalTo(typeImgV)
        }
        
        bgImgV.addSubview(productImgV)
        productImgV.layer.cornerRadius = Screen_IPadMultiply(3)
        productImgV.layer.masksToBounds = true
        productImgV.snp.makeConstraints { make in
            make.left.equalTo(typeImgV)
            make.top.equalTo(typeImgV.snp.bottom).offset(Screen_IPadMultiply(8))
            make.width.height.equalTo(Screen_IPadMultiply(86))
        }
        
        bgImgV.addSubview(productNameLb)
        productNameLb.numberOfLines = 2
        productNameLb.textColor = Color_Hex(0x262626)
        productNameLb.font = Font_Medium_IPadMul(14)
        productNameLb.snp.makeConstraints { make in
            make.left.equalTo(productImgV.snp.right).offset(Screen_IPadMultiply(10))
            make.top.equalTo(productImgV)
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-20))
        }
        
        bgImgV.addSubview(productPriceLb)
        productPriceLb.snp.makeConstraints { make in
            make.left.equalTo(productNameLb)
            make.bottom.equalTo(productImgV.snp.bottom).offset(Screen_IPadMultiply(4))
            make.height.equalTo(Screen_IPadMultiply(28))
        }
        
        bgImgV.addSubview(statusNoneLb)
        statusNoneLb.backgroundColor = Color_Hex(0x999999)
        statusNoneLb.textColor = .white
        statusNoneLb.textAlignment = .center
        statusNoneLb.font = Font_Medium_IPadMul(10)
        statusNoneLb.text = "已失效"
        statusNoneLb.layer.cornerRadius = Screen_IPadMultiply(9)
        statusNoneLb.layer.masksToBounds = true
        statusNoneLb.snp.makeConstraints { make in
            make.left.equalTo(productNameLb)
            make.width.equalTo(Screen_IPadMultiply(50))
            make.height.equalTo(Screen_IPadMultiply(18))
            make.top.equalTo(productNameLb.snp.bottom).offset(Screen_IPadMultiply(8))
        }
        statusNoneLb.isHidden = true
        
        bgImgV.addSubview(moneyImgV)
        moneyImgV.addSubview(moneyNumLb)
        moneyNumLb.textAlignment = .center
    }
    
    func getTypeImageName(type: String) -> String {
        var imageN = ""
        switch type {
        case "pdd":
            imageN = "order_pdd_icon"
        case "jd":
            imageN = "order_jd_icon"
        case "taobao":
            imageN = "order_taobao_icon"
        default:
            break
        }
        return imageN
    }
    
    func handlePriceString(_ rebateStatus: String, price: String) {
        let att = NSMutableAttributedString(string: price)
        var priceColor = Color_Hex(0xE11521)
        if rebateStatus == "3" {
            priceColor = Color_Hex(0x999999)
            att.addAttributes([.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: priceColor], range: NSRange(location: 1, length: price.count - 1))
        }
        att.addAttributes([.font: Font_Medium_IPadMul(12), .foregroundColor: priceColor], range: NSRange(location: 0, length: 1))
        att.addAttributes([.font: Font_Medium_IPadMul(20), .foregroundColor: priceColor], range: NSRange(location: 1, length: price.count - 1))
        productPriceLb.attributedText = att
    }
}
