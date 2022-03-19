//
//  TYShopProductTypeView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/14.
//

import UIKit
import BaseModule

class TYShopProductTypeView: UIView {
    
    var platformTypeClosure: ((Int)->Void)?
    
    private var jdBtn = UIButton()
    private var pddBtn = UIButton()
    private var tbBtn = UIButton()
    
    private var selectedBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSelected(type: Int) {
        if let btn = viewWithTag(type) as? UIButton {
            if selectedBtn != btn {
                selectedBtn.isSelected = false
                btn.isSelected = true
                selectedBtn = btn
            }
        }
    }
}

private extension TYShopProductTypeView {
    func createSubviews() {
        backgroundColor = Color_Hex(0xF8F8F8)
        
        addSubview(pddBtn)
        refreshBtn(pddBtn, title: "拼多多", tag: 3)
        pddBtn.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(84))
            make.height.equalTo(Screen_IPadMultiply(28))
            make.center.equalToSuperview()
        }
        
        addSubview(jdBtn)
        refreshBtn(jdBtn, title: "京东", tag: 1)
        jdBtn.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(pddBtn)
            make.right.equalTo(pddBtn.snp.left).offset(Screen_IPadMultiply(-10))
        }
        
        addSubview(tbBtn)
        refreshBtn(tbBtn, title: "淘宝", tag: 2)
        tbBtn.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(pddBtn)
            make.left.equalTo(pddBtn.snp.right).offset(Screen_IPadMultiply(10))
        }
    }
    
    func refreshBtn(_ btn: UIButton, title: String, tag: Int) {
        btn.layer.cornerRadius = Screen_IPadMultiply(6)
        btn.layer.masksToBounds = true
        btn.setBackgroundColor(Color_Hex(0xFFFFFF), for: .normal)
        btn.setBackgroundColor(Color_Hex(0xE11521), for: .selected)
        btn.setTitleColor(Color_Hex(0xFFFFFF), for: .selected)
        btn.setTitleColor(Color_Hex(0x595959), for: .normal)
        btn.titleLabel?.font = Font_System_IPadMul(14)
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        btn.tag = tag
    }
    
    @objc func btnClick(_ btn: UIButton) {
        if selectedBtn == btn {
            return
        }
        btn.isSelected = true
        selectedBtn.isSelected = false
        selectedBtn = btn
        platformTypeClosure?(btn.tag)
    }
}
