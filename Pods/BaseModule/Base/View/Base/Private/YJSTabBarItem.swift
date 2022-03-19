//
//  YJSTabBarItem.swift
//  YouShaQi
//
//  Created by Beginner on 2019/7/29.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class YJSTabBarItem: UIView {
    enum YJSTabBarItemStatus {
        case Normal
        case Selected
    }
    enum YJSTabBarItemBadgeStyle {
        case dot
        case num
    }
    private var _status: YJSTabBarItemStatus = .Normal
    var status: YJSTabBarItemStatus {
        get {
            return _status
        }
        set {
            _status = newValue
            refreshView()
        }
    }
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    private var badgeView = UILabel()
    private var badgeStyle = YJSTabBarItemBadgeStyle.dot
    private var badgeValue = 0
    var dicStateImage = [YJSTabBarItemStatus: UIImage]()
    var dicStateTitle = [YJSTabBarItemStatus: String]()
    var dicStateTitleFont = [YJSTabBarItemStatus: UIFont]()
    var dicStateTitleColor = [YJSTabBarItemStatus: UIColor]()
    var dicStateBadgeStyle = [YJSTabBarItemStatus: YJSTabBarItemBadgeStyle]()
    var onClickHandler: ((YJSTabBarItem) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
        setupDefaultAttr()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onClickedView))
        addGestureRecognizer(tap)
        
        imageView = UIImageView.init()
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(5)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        badgeView = UILabel()
        addSubview(badgeView)
        badgeView.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp_right).offset(-3)
            make.top.equalTo(imageView)
            make.size.equalTo(CGSize(width: 8, height: 8))
        }
        badgeView.backgroundColor = UIColor.red
        badgeView.textColor = .white
        badgeView.textAlignment = .center
        badgeView.font = UIFont.systemFont(ofSize: 8)
        badgeView.layer.cornerRadius = 4
        badgeView.layer.masksToBounds = true
        
        
        titleLabel = UILabel.init()
        addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp_bottom).offset(2)
            make.left.right.equalTo(self)
        }
        titleLabel.textAlignment = .center
    }
    
    func setupDefaultAttr() {
        dicStateTitleFont[.Normal] = UIFont.systemFont(ofSize: 10.0)
        dicStateBadgeStyle[.Normal] = .dot
        status = .Normal
        badgeValue = 0
        badgeStyle = .dot
    }
    
    func setImage(_ image: UIImage?, forStatus status: YJSTabBarItemStatus) {
        if image == nil {
            return
        }
        dicStateImage[status] = image
        refreshView()
    }
    
    func setTitle(_ title: String?, forStatus status: YJSTabBarItemStatus) {
        if title!.isEmpty {
            return
        }
        dicStateTitle[status] = title
        refreshView()
    }
    
    func setTitleFont(_ font: UIFont?, forStatus status: YJSTabBarItemStatus) {
        if font == nil {
            return
        }
        dicStateTitleFont[status] = font
        refreshView()
    }
    
    func setTitleColor(_ color: UIColor?, forStatus status: YJSTabBarItemStatus) {
        if color == nil {
            return
        }
        dicStateTitleColor[status] = color
        refreshView()
    }
    
    func setBadgeStyle(_ style: YJSTabBarItemBadgeStyle, forStatus status: YJSTabBarItemStatus) {
        dicStateBadgeStyle[status] = style
        refreshView()
    }
    
    func setBadgeValue(_ value: Int) {
        badgeValue = value
        refreshView()
    }
    
    func refreshView() {
        let defaultImage = dicStateImage[.Normal]
        let defaultTitle = dicStateTitle[.Normal]
        let defaultTitleFont = dicStateTitleFont[.Normal]
        let defaultTitleColor = dicStateTitleColor[.Normal]
        
        let newImage = dicStateImage[status]
        let newTitle = dicStateTitle[status]
        let newTitleFont = dicStateTitleFont[status]
        let newTitleColor = dicStateTitleColor[status]
        let newBadgeStyle = dicStateBadgeStyle[status]
        
        imageView.image = newImage ?? defaultImage
        titleLabel.text = newTitle ?? defaultTitle
        titleLabel.font = newTitleFont ?? defaultTitleFont
        titleLabel.textColor = newTitleColor ?? defaultTitleColor
        badgeStyle = newBadgeStyle ?? .dot
        
        badgeView.isHidden = (badgeValue == 0)
        switch badgeStyle {
        case .num:
            badgeView.text = String(badgeValue)
            var width = 12
            if badgeValue > 9 && badgeValue <= 99 {
                width = 20
            } else if badgeValue > 99 {
                width = 24
                badgeView.text = "99+"
            }
            badgeView.snp.remakeConstraints { (make) in
                make.left.equalTo(imageView.snp_right).offset(-3)
                make.top.equalTo(imageView)
                make.size.equalTo(CGSize(width: width, height: 12))
            }
            badgeView.layer.cornerRadius = 6
            
        default:
            badgeView.snp.remakeConstraints { (make) in
                make.left.equalTo(imageView.snp_right).offset(-3)
                make.top.equalTo(imageView)
                make.size.equalTo(CGSize(width: 8, height: 8))
            }
            badgeView.layer.cornerRadius = 4
            badgeView.text = ""
        }
    }
    
    @objc func onClickedView() {
        if onClickHandler != nil {
            onClickHandler!(self)
        }
    }
}
