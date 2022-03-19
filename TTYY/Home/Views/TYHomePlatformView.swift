//
//  TYHomePlatformView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/2.
//

import UIKit
import BaseModule

class TYHomePlatformView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension TYHomePlatformView {
    func createSubviews() {
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x999999)
        tipLb.font = Font_System_IPadMul(14)
        tipLb.textAlignment = .center
        tipLb.text = "-合作商家-"
        addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(24))
        }
        let eleme = TYPlatformCellView()
        eleme.platformType = .eleme
        eleme.loadData(title:"饿了么", image: UIImage(named: "home_eleme_icon")!, tip: "最高返红包", tipPost: "5%", packet: "红包补贴", backgroundColor: UIColor.init(rgbHex: 0x0278FC, alpha: 0.06))
        addSubview(eleme)
        let margin = Screen_IPadMultiply(30)
        let width = (Screen_Width - CGFloat(2 * margin) - Screen_IPadMultiply(11)) / 2.0
        eleme.snp.makeConstraints { make in
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(12))
            make.width.equalTo(width)
            make.height.equalTo(Screen_IPadMultiply(64))
            make.left.equalTo(margin)
        }
        
        
        let meituan = TYPlatformCellView()
        meituan.platformType = .meituan
        meituan.loadData(title:"美团", image: UIImage(named: "home_mt_icon")!, tip: "下单返红包", tipPost: "2%", packet: "下单返红包", backgroundColor: UIColor.init(rgbHex: 0xFCAA02, alpha: 0.06))
        addSubview(meituan)
        meituan.snp.makeConstraints { make in
            make.top.equalTo(eleme.snp.top)
            make.width.height.equalTo(eleme)
            make.right.equalTo(-margin)
        }
        
        let taobao = TYPlatformCellView()
        taobao.platformType = .taobao
        taobao.loadData(title:"淘宝", image: UIImage(named: "home_tb_icon")!, tip: "最高返红包", tipPost: "48%", packet: "", backgroundColor: UIColor.init(rgbHex: 0xFC7502, alpha: 0.06))
        addSubview(taobao)
        taobao.snp.makeConstraints { make in
            make.top.equalTo(eleme.snp.bottom).offset(11)
            make.width.height.equalTo(eleme)
            make.left.equalTo(margin)
        }
        
        let pdd = TYPlatformCellView()
        pdd.platformType = .pdd
        pdd.loadData(title:"拼多多", image: UIImage(named: "home_pdd_icon")!, tip: "最高返红包", tipPost: "50%", packet: "", backgroundColor: UIColor.init(rgbHex: 0xFC0202, alpha: 0.06))
        addSubview(pdd)
        pdd.snp.makeConstraints { make in
            make.top.equalTo(eleme.snp.bottom).offset(11)
            make.width.height.equalTo(eleme)
            make.right.equalTo(-margin)
        }
        
        let jd = TYPlatformCellView()
        jd.platformType = .jd
        jd.loadData(title:"京东", image: UIImage(named: "home_jd_icon")!, tip: "最高返红包", tipPost: "36%", packet: "", backgroundColor: UIColor.init(rgbHex: 0xFC0202, alpha: 0.06))
        addSubview(jd)
        jd.snp.makeConstraints { make in
            make.top.equalTo(taobao.snp.bottom).offset(11)
            make.width.height.equalTo(eleme)
            make.left.equalTo(margin)
        }
    }
}
