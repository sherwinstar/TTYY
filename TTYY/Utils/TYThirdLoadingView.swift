//
//  TYThirdLoadingView.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/20.
//

import UIKit
import BaseModule

class TYThirdLoadingView: UIView {
    private var contentView = UIView()
    private var type: TYThirdLoadingType?
    class func show(type: TYThirdLoadingType) {
        if let subV = UIApplication.shared.keyWindow?.viewWithTag(100012) {
            subV.removeFromSuperview()
        }
        let loadingView = TYThirdLoadingView()
        loadingView.type = type
        loadingView.createSubview()
        loadingView.tag = 100012
        UIApplication.shared.keyWindow?.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    class func remveView() {
        if let subV = UIApplication.shared.keyWindow?.viewWithTag(100012) {
            subV.removeFromSuperview()
        }
    }
}

private extension TYThirdLoadingView {
    func createSubview() {
        backgroundColor = Color_HexA(0x000000, alpha: 0.6)
        addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Screen_IPadMultiply(10)
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(309), height: Screen_IPadMultiply(164)))
            make.center.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        let att = NSMutableAttributedString(string: "下单商品返红包哦", attributes: [.font: Font_Semibold_IPadMul(18), .foregroundColor: Color_Hex(0x262626)])
        att.addAttributes([.foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: 4, length: 3))
        titleLabel.attributedText = att
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(Screen_IPadMultiply(23))
            make.height.equalTo(Screen_IPadMultiply(25))
        }
        
        let thirdImageView = UIImageView()
        var image = UIImage(named: "home_tb_icon")
        switch type! {
        case .pdd:
            image = UIImage(named: "home_pdd_icon")
        case .eleme:
            image = UIImage(named: "home_eleme_icon")
        case .meituan:
            image = UIImage(named: "home_mt_icon")
        case .taobao:
            image = UIImage(named: "home_tb_icon")
        case .jd:
            image = UIImage(named: "home_jd_icon")
        }
        thirdImageView.image = image
        let ttyyImageView = UIImageView()
        image = UIImage(named: "home_ttyy_icon")
        ttyyImageView.image = image
        contentView.addSubview(thirdImageView)
        contentView.addSubview(ttyyImageView)
        ttyyImageView.snp.makeConstraints { make in
            make.left.equalTo(Screen_IPadMultiply(62))
            make.bottom.equalTo(Screen_IPadMultiply(-36))
            make.height.width.equalTo(Screen_IPadMultiply(52))
        }
        thirdImageView.snp.makeConstraints { make in
            make.right.equalTo(Screen_IPadMultiply(-62))
            make.bottom.equalTo(Screen_IPadMultiply(-36))
            make.height.width.equalTo(Screen_IPadMultiply(52))
        }
        
        let img = Bundle.main.url(forResource: "third_loading", withExtension: "gif")
            .flatMap { try? Data.init(contentsOf: $0) }
            .flatMap { UIImage.sd_animatedGIF(with: $0) }
        let imgView = UIImageView.init(image: img)
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(Screen_IPadMultiply(-44))
            make.width.equalTo(Screen_IPadMultiply(76))
            make.height.equalTo(Screen_IPadMultiply(36))
        }
    }
}
