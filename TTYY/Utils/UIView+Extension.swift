//
//  UIViewExpand.swift
//  TestBreath
//
//  Created by Shaolin Zhou on 2021/11/1.
//

import Foundation
import UIKit

extension UIView {
    func pulse(withDuration duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse,.curveEaseInOut,.allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (true) in
            self.transform = CGAffineTransform.identity
        }
    }
    
    func pulse2(withDuration duration: Double){
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = duration
        scaleAnimation.autoreverses = true
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.repeatCount = Float(INT_MAX);
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(scaleAnimation, forKey: "transform")
    }
    
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

extension UIView {
    //添加4个不同大小的圆角
    public func addCorner(cornerRadius: CornerRadius, borderColor: UIColor, borderWidth: CGFloat){
        let path = createPathWithRoundedRect(bounds: self.bounds, cornerRadius:cornerRadius)
        let shapLayer = CAShapeLayer()
        shapLayer.frame = self.bounds
        shapLayer.path = path
        let borderLayer = CAShapeLayer();
        borderLayer.frame = self.bounds;
        borderLayer.path = path;
        borderLayer.lineWidth = borderWidth;
        borderLayer.fillColor = UIColor.clear.cgColor;
        borderLayer.strokeColor = borderColor.cgColor;
        self.layer.addSublayer(borderLayer)
        self.layer.mask = shapLayer
    }
    //各圆角大小
    public struct CornerRadius {
        var topLeft :CGFloat = 0
        var topRight :CGFloat = 0
        var bottomLeft :CGFloat = 0
        var bottomRight :CGFloat = 0
        
        public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
   }
    
    //切圆角函数绘制线条
    func createPathWithRoundedRect ( bounds:CGRect,cornerRadius:CornerRadius) -> CGPath {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        //获取四个圆心
        let topLeftCenterX = minX +  cornerRadius.topLeft
        let topLeftCenterY = minY + cornerRadius.topLeft
         
        let topRightCenterX = maxX - cornerRadius.topRight
        let topRightCenterY = minY + cornerRadius.topRight
        
        let bottomLeftCenterX = minX +  cornerRadius.bottomLeft
        let bottomLeftCenterY = maxY - cornerRadius.bottomLeft
         
        let bottomRightCenterX = maxX -  cornerRadius.bottomRight
        let bottomRightCenterY = maxY - cornerRadius.bottomRight
        
        //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
        let path :CGMutablePath = CGMutablePath();
         //顶 左
        path.addArc(center: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: cornerRadius.topLeft, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        //顶右
        path.addArc(center: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: cornerRadius.topRight, startAngle: CGFloat.pi * 3 / 2, endAngle: 0, clockwise: false)
        //底右
        path.addArc(center: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: cornerRadius.bottomRight, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
        //底左
        path.addArc(center: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: cornerRadius.bottomLeft, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: false)
        path.closeSubpath();
        return path;
    }
    
}
