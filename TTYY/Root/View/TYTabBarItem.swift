//
//  TYTabBarItem.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import BaseModule

class TYTabBarItem: UIView {
    enum TYTabBarItemStatus {
        case Normal
        case Selected
    }
    enum TYTabBarItemBadgeStyle {
        case dot
        case num
    }
    private var _status: TYTabBarItemStatus = .Normal
    var status: TYTabBarItemStatus {
        get {
            return _status
        }
        set {
            _status = newValue
            ty_refreshView()
        }
    }
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    private var badgeView = UILabel()
    private var badgeStyle = TYTabBarItemBadgeStyle.dot
    private var badgeValue = 0
    var dicStateImage = [TYTabBarItemStatus: UIImage]()
    var dicStateTitle = [TYTabBarItemStatus: String]()
    var dicStateTitleFont = [TYTabBarItemStatus: UIFont]()
    var dicStateTitleColor = [TYTabBarItemStatus: UIColor]()
    var dicStateBadgeStyle = [TYTabBarItemStatus: TYTabBarItemBadgeStyle]()
    var onClickHandler: ((TYTabBarItem) -> Void)?
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
            make.left.equalTo(self.imageView.snp.right).offset(-3)
            make.top.equalTo(self.imageView)
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
            make.top.equalTo(self.imageView.snp.bottom).offset(2)
            make.left.right.equalTo(self)
        }
        titleLabel.textAlignment = .center
    }
    
    func setupDefaultAttr() {
        dicStateTitleFont[.Normal] = UIFont.systemFont(ofSize: 10.0)
        dicStateBadgeStyle[.Normal] = .dot
        dicStateTitleColor[.Normal] = .black
        dicStateTitleColor[.Selected] = Color_Hex(0xE11521)
        status = .Normal
        badgeValue = 0
        badgeStyle = .dot
    }
    
    func ty_setImage(_ image: UIImage?, forStatus status: TYTabBarItemStatus) {
        if image == nil {
            return
        }
        dicStateImage[status] = image
        ty_refreshView()
    }
    
    func ty_setTitle(_ title: String?, forStatus status: TYTabBarItemStatus) {
        if title!.isEmpty {
            return
        }
        dicStateTitle[status] = title
        ty_refreshView()
    }
    
    func ty_setTitleFont(_ font: UIFont?, forStatus status: TYTabBarItemStatus) {
        if font == nil {
            return
        }
        dicStateTitleFont[status] = font
        ty_refreshView()
    }
    
    func ty_setTitleColor(_ color: UIColor?, forStatus status: TYTabBarItemStatus) {
        if color == nil {
            return
        }
        dicStateTitleColor[status] = color
        ty_refreshView()
    }
    
    func setBadgeStyle(_ style: TYTabBarItemBadgeStyle, forStatus status: TYTabBarItemStatus) {
        dicStateBadgeStyle[status] = style
        ty_refreshView()
    }
    
    func setBadgeValue(_ value: Int) {
        badgeValue = value
        ty_refreshView()
    }
    
    func ty_refreshView() {
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
                make.left.equalTo(self.imageView.snp.right).offset(-3)
                make.top.equalTo(self.imageView)
                make.size.equalTo(CGSize(width: width, height: 12))
            }
            badgeView.layer.cornerRadius = 6
            
        default:
            badgeView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.imageView.snp.right).offset(-3)
                make.top.equalTo(self.imageView)
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
