//
//  TYShopGoodHeadView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

class TYShopGoodHeadView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYShopGoodHeadView {
    func createSubviews() {
        backgroundColor = Color_Hex(0xF8F8F8)
        let icon = UIImageView(image: UIImage(named: "shop_splash_icon"))
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.width.equalTo(Screen_IPadMultiply(14))
            make.height.equalTo(Screen_IPadMultiply(17))
            make.centerY.equalToSuperview()
        }
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x262626)
        tipLb.text = "超级爆品"
        tipLb.font = Font_Bold_IPadMul(18)
        addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(Screen_IPadMultiply(2))
            make.centerY.equalToSuperview()
        }
        
//        let moreBtn = TYBindSkipButton()
//        moreBtn.titleLabel?.font = Font_System_IPadMul(12)
//        moreBtn.setTitleColor(Color_Hex(0x262626), for: .normal)
//        moreBtn.contentHorizontalAlignment = .right
//        moreBtn.setTitle("更多爆款", for: .normal)
//        moreBtn.setImage(UIImage(named: "bind_skip_arrow"), for: .normal)
//        addSubview(moreBtn)
//        moreBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(Screen_IPadMultiply(-20))
//            make.centerY.equalToSuperview()
//            make.width.equalTo(Screen_IPadMultiply(120))
//            make.height.equalTo(Screen_IPadMultiply(30))
//        }
    }
}
