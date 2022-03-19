//
//  YJSActionImgView.swift
//  BaseModule
//
//  Created by Admin on 2020/9/4.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

/*
 可点击的圆角图片：必须要在绘制圆角之前给 YJSActionImgView 正确的大小
 绘制圆角的触发时机是：image 和 cornerRadius 中的任意一个发生改变时，并且它们同时有值时
 给正确大小的两种方式：
 （1）直接在初始化时，给 frame 设置正确值
 （2）用自动布局，在触发绘制圆角之前调用 layoutIfNeeded
 */
public class YJSActionImgView: UIImageView {
    private let tap: UITapGestureRecognizer
    
    public var clickClosure: () -> ()
    
    public var cornerRadius: CGFloat = 0 {
        willSet {
            if newValue != cornerRadius {
                drawCornerRadius(newValue)
            }
        }
    }
    
    public override var image: UIImage? {
        didSet {
            drawCornerRadius(cornerRadius)
        }
    }
    
    public init(frame: CGRect, click: @escaping () -> ()) {
        clickClosure = click
        tap = UITapGestureRecognizer()
        super.init(frame: frame)
        tap.addTarget(self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap() {
        clickClosure()
    }
    
    private func drawCornerRadius(_ radius: CGFloat) {
        guard let originImg = image, radius > 0 else {
            return
        }
        roundCorners(radius: radius)
    }
}
