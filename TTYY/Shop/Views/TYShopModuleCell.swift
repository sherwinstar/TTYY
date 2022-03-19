//
//  TYShopModuleCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

enum ShopModuleType: Int {
    case newFree = 1    // 新人免单
    case free99     // 9.9包邮
    case ticket     // 好券商品
    case commission     // 高佣榜单
    case meituan      //
    case jd      // 京东
    case pdd      //
    case taobao      //
    case elme      //
}

class TYShopModuleCell: UITableViewCell {
    
    var moduleActionClosure: ((ShopModuleType)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYShopModuleCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        let btnW = Screen_IPadMultiply(50)
        let btnH = Screen_IPadMultiply(62)
        let margin = (Screen_Width - 4 * btnW) / 5
        
        let free99 = createModuleBtn(title: "9.9包邮", imageN: "shop_99_icon", type: .free99)
        contentView.addSubview(free99)
        free99.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.width.equalTo(btnW)
            make.height.equalTo(btnH)
        }
        
        let ticketBtn = createModuleBtn(title: "好券商品", imageN: "shop_ticket_icon", type: .ticket)
        contentView.addSubview(ticketBtn)
        ticketBtn.snp.makeConstraints { make in
            make.left.equalTo(free99.snp.right).offset(margin)
            make.top.width.height.equalTo(free99)
        }
        
        let commissionBtn = createModuleBtn(title: "高佣榜单", imageN: "shop_commission_icon", type: .commission)
        contentView.addSubview(commissionBtn)
        commissionBtn.snp.makeConstraints { make in
            make.left.equalTo(ticketBtn.snp.right).offset(margin)
            make.top.width.height.equalTo(free99)
        }
        
        let meitBtn = createModuleBtn(title: "美团", imageN: "shop_mt_icon", type: .meituan)
        contentView.addSubview(meitBtn)
        meitBtn.snp.makeConstraints { make in
            make.left.equalTo(commissionBtn.snp.right).offset(margin)
            make.top.width.height.equalTo(free99)
            make.top.width.height.equalTo(free99)
        }
        
        let jdBtn = createModuleBtn(title: "京东", imageN: "shop_jd_icon", type: .jd)
        contentView.addSubview(jdBtn)
        jdBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(free99.snp.bottom).offset(Screen_IPadMultiply(15))
            make.width.height.equalTo(free99)
        }
        
        let pddBtn = createModuleBtn(title: "拼多多", imageN: "shop_pdd_icon", type: .pdd)
        contentView.addSubview(pddBtn)
        pddBtn.snp.makeConstraints { make in
            make.left.equalTo(jdBtn.snp.right).offset(margin)
            make.top.width.height.equalTo(jdBtn)
        }
        
        let taobaoBtn = createModuleBtn(title: "淘宝", imageN: "shop_taobao_icon", type: .taobao)
        contentView.addSubview(taobaoBtn)
        taobaoBtn.snp.makeConstraints { make in
            make.left.equalTo(pddBtn.snp.right).offset(margin)
            make.top.width.height.equalTo(jdBtn)
        }
        let lucky11 = UILabel()
        lucky11.text = "狂欢11"
        lucky11.textColor = .white
        lucky11.backgroundColor = .red//UIColor.init(rgbHex: 0xF7313D)
        lucky11.font = Font_Medium_IPadMul(10)
        lucky11.textAlignment = .center
        contentView.addSubview(lucky11)
        lucky11.layer.masksToBounds = true
        
        lucky11.frame = CGRect(x: 2 * btnW + 3 * margin + Screen_IPadMultiply(14), y: Screen_IPadMultiply(25) + btnH - 8, width: Screen_IPadMultiply(37), height: Screen_IPadMultiply(18))
        let corner = CornerRadius(topLeft: Screen_IPadMultiply(18) / 2, topRight: Screen_IPadMultiply(18) / 2, bottomLeft: Screen_IPadMultiply(2), bottomRight: Screen_IPadMultiply(18) / 2)
        lucky11.addCorner(cornerRadius: corner, borderColor: .white, borderWidth: 1)
        
//        lucky11.snp.makeConstraints { make in
//            make.top.equalTo(taobaoBtn.snp.top).offset(-8)
//            make.width.equalTo(Screen_IPadMultiply(37))
//            make.height.equalTo(Screen_IPadMultiply(18))
//            make.left.equalTo(taobaoBtn.snp.left).offset(Screen_IPadMultiply(14))
//        }
        lucky11.setAnchorPoint(CGPoint(x: 0, y: 1))
        lucky11.pulse2(withDuration: 0.8)
        
        let elmeBtn = createModuleBtn(title: "饿了么", imageN: "shop_eleme_icon", type: .elme)
        contentView.addSubview(elmeBtn)
        elmeBtn.snp.makeConstraints { make in
            make.left.equalTo(taobaoBtn.snp.right).offset(margin)
            make.top.width.height.equalTo(jdBtn)
        }
        
        let luckyPacketLabel = UILabel()
        luckyPacketLabel.text = "红包补贴"
        luckyPacketLabel.textColor = .white
        luckyPacketLabel.backgroundColor = UIColor.init(rgbHex: 0xF7313D)
        luckyPacketLabel.font = Font_Medium_IPadMul(10)
        luckyPacketLabel.textAlignment = .center
        contentView.addSubview(luckyPacketLabel)
        luckyPacketLabel.layer.masksToBounds = true
        
        luckyPacketLabel.frame = CGRect(x: 3 * btnW + 4 * margin + Screen_IPadMultiply(14), y: Screen_IPadMultiply(25) + btnH - 8, width: Screen_IPadMultiply(49), height: Screen_IPadMultiply(18))
        let corner2 = CornerRadius(topLeft: Screen_IPadMultiply(18) / 2, topRight: Screen_IPadMultiply(18) / 2, bottomLeft: Screen_IPadMultiply(2), bottomRight: Screen_IPadMultiply(18) / 2)
        luckyPacketLabel.addCorner(cornerRadius: corner2, borderColor: .white, borderWidth: 1)
//        luckyPacketLabel.snp.makeConstraints { make in
//            make.top.equalTo(elmeBtn.snp.top).offset(-8)
//            make.width.equalTo(Screen_IPadMultiply(49))
//            make.height.equalTo(Screen_IPadMultiply(18))
//            make.left.equalTo(elmeBtn.snp.left).offset(Screen_IPadMultiply(14))
//        }
        luckyPacketLabel.setAnchorPoint(CGPoint(x: 0, y: 1))
        luckyPacketLabel.pulse2(withDuration: 0.8)
    }
    
    func createModuleBtn(title: String, imageN: String, type: ShopModuleType) -> TYModuleButton {
        let btn = TYModuleButton.init()
        btn.tag = type.rawValue
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(Color_Hex(0x595959), for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = Font_Medium_IPadMul(12)
        btn.setImage(UIImage(named: imageN), for: .normal)
        btn.setImage(UIImage(named: imageN), for: .highlighted)
        btn.addTarget(self, action: #selector(moduleBtnClick(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc func moduleBtnClick(_ btn: TYModuleButton) {
        if let type = ShopModuleType.init(rawValue: btn.tag) {
            moduleActionClosure?(type)
        }
    }
}
