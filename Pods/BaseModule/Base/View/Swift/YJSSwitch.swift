//
//  YJSSwitch.swift
//  BaseModule
//
//  Created by Admin on 2020/11/17.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit

@objc public class YJSSwitch: UIView {
    private var titles: [String]
    private var selTitleColor: UIColor = Color_Hex(0x393C3E)
    private var unselTitleColor: UIColor = Color_Hex(0x879099)
    private var selBgColor: UIColor = .white
    private var unselBgColor: UIColor = Color_Hex(0xEDF1F4)
    private var actionClosure: ((Bool)->())?
    private var isLeftSelected: Bool
    
    private var selView = UIView()
    private var leftBtn = UIButton(type: .custom)
    private var rightBtn = UIButton(type: .custom)
    
    @objc public init(frame: CGRect, titles: [String], actionClosure: ((Bool)->())?, defaultSelectLeft: Bool, selTitleColor: UIColor, unselTitleColor: UIColor, selBgColor: UIColor, unselBgColor: UIColor) {
        self.titles = titles
        self.actionClosure = actionClosure
        self.selTitleColor = selTitleColor
        self.unselTitleColor = unselTitleColor
        self.selBgColor = selBgColor
        self.unselBgColor = unselBgColor
        isLeftSelected = defaultSelectLeft
        super.init(frame: frame)
        createView()
    }
    
    @objc public init(frame: CGRect, titles: [String], actionClosure: ((Bool)->())?, defaultSelectLeft: Bool) {
        self.titles = titles
        self.actionClosure = actionClosure
        isLeftSelected = defaultSelectLeft
        super.init(frame: frame)
        createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createView() {
        addSubview(selView)
        selView.backgroundColor = selBgColor
        
        // 确定title
        for i in 0...1 {
            if self.titles.count <= i {
                self.titles.append("")
            }
        }
        
        addSubview(leftBtn)
        leftBtn.backgroundColor = .clear
        leftBtn.setTitleColor(selTitleColor, for: .selected)
        leftBtn.setTitleColor(unselTitleColor, for: .normal)
        leftBtn.setTitle(self.titles[0], for: .normal)
        leftBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        leftBtn.addTarget(self, action: #selector(handleLeftAction), for: .touchUpInside)
        leftBtn.isSelected = isLeftSelected

        addSubview(rightBtn)
        rightBtn.backgroundColor = .clear
        rightBtn.setTitleColor(selTitleColor, for: .selected)
        rightBtn.setTitleColor(unselTitleColor, for: .normal)
        rightBtn.setTitle(self.titles[1], for: .normal)
        rightBtn.titleLabel?.font = Font_Medium_IPadMul(12)
        rightBtn.addTarget(self, action: #selector(handleRightAction), for: .touchUpInside)

        self.backgroundColor = unselBgColor
        
        leftBtn.snp.makeConstraints { (make) in
            make.bottom.left.top.equalToSuperview()
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.bottom.right.top.equalToSuperview()
            make.left.equalTo(leftBtn.snp_right)
            make.width.equalTo(leftBtn)
        }
        
        if isLeftSelected {
            showLeft(animation: false)
        } else {
            showRight(animation: false)
        }
    }
    
    private func showLeft(animation: Bool) {
        show(animation: animation) {
            self.selView.snp.remakeConstraints { (make) in
                make.left.top.equalToSuperview().offset(2)
                make.bottom.equalToSuperview().offset(-2)
                make.right.equalTo(self.snp_centerX)
            }
        }
    }
    
    private func showRight(animation: Bool) {
        show(animation: animation) {
            self.selView.snp.remakeConstraints { (make) in
                make.right.bottom.equalToSuperview().offset(-2)
                make.top.equalToSuperview().offset(2)
                make.left.equalTo(self.snp_centerX)
            }
        }
    }
    
    private func show(animation: Bool, _ closure: @escaping ()->()) {
        if animation {
            UIView.animate(withDuration: 0.35) {
                closure()
                self.layoutIfNeeded()
            }
        } else {
            closure()
        }
    }
    
    public override func layoutSubviews() {
        selView.layer.cornerRadius = swift_height / 2.0
        layer.cornerRadius = swift_height / 2.0
    }
    
    @objc func handleLeftAction() {
        if isLeftSelected {
            return
        }
        isLeftSelected = true
        leftBtn.isSelected = true
        rightBtn.isSelected = false
        showLeft(animation: true)
        actionClosure?(true)
    }
    
    @objc func handleRightAction() {
        if !isLeftSelected {
            return
        }
        isLeftSelected = false
        leftBtn.isSelected = false
        rightBtn.isSelected = true
        showRight(animation: true)
        actionClosure?(false)
    }
}
