//
//  YJSAvaterView.swift
//  BaseModule
//
//  Created by Admin on 2020/10/19.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public protocol YJSAvaterViewDelegate {
    func avaterViewDidClick(_ avaterView: YJSAvaterView)
}

public class YJSAvaterView: UIImageView {
    #if TARGET_ZSSQ
    public static var defaultAvaterImgName = "phone_login_default_avatar"
    #else
    public static var defaultAvaterImgName = "mine_defualt_head"
    #endif
    
    public var defaultAvaterImgName: String?
    public var radius: CGFloat?
    public var urlString: String?
    public var delegate: YJSAvaterViewDelegate?
    
    private var tap: UITapGestureRecognizer?
    
    /// 初始化
    /// - Parameters:
    ///   - radius: 空表示没有圆角
    ///   - url: 空表示暂时没有URL
    ///   - delegate: 空表示不支持点击操作
    ///   - frame: 空表示.zero
    public init(radius: CGFloat?, url: String?, delegate: YJSAvaterViewDelegate? = nil, frame: CGRect? = nil, defaultImgName: String? = nil) {
        self.radius = radius
        self.urlString = url
        self.delegate = delegate
        self.defaultAvaterImgName = defaultImgName
        super.init(frame: frame ?? .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        didSetImageUrl()
        didSetRadius()
        if let delegate = self.delegate {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(_:)))
            self.addGestureRecognizer(tap)
            self.tap = tap
        }
    }
    
    @objc private func handleTapAction(_ tap: UITapGestureRecognizer) {
        self.delegate?.avaterViewDidClick(self)
    }
    
    public func update(url: String?) {
        self.urlString = url
        didSetImageUrl()
    }
    
    public func update(url: URL?) {
        self.urlString = url?.absoluteString
        didSetImageUrl()
    }
    
    private func didSetImageUrl() {
        let url = urlString?.yjs_queryEncodedURLString().flatMap { URL(string: $0) }
        let placeholderImg = (defaultAvaterImgName ?? YJSAvaterView.defaultAvaterImgName)
            .flatMap { UIImage(named: $0) }
            ?? UIImage()
        if let url = url {
            sd_setImage(with: url, placeholderImage: placeholderImg)
        } else {
            image = placeholderImg
        }
    }
    
    public func update(radius: CGFloat) {
        self.radius = radius
        didSetRadius()
    }
    
    private func didSetRadius() {
        if let radius = self.radius {
            layer.cornerRadius = radius
            layer.masksToBounds = true
        }
    }
    
    public func update(defaultImgName: String) {
        self.image = UIImage(named: defaultImgName)
    }
}
