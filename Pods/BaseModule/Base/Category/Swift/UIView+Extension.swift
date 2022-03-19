//
//  UIView+Extension.swift
//  YouShaQi
//
//  Created by 杨旭 on 2019/9/6.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit

//MARK: - frame
extension UIView {
    public var swift_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var tempFrame: CGRect = frame
            tempFrame.origin.x = newValue
            frame = tempFrame
        }
    }
    
    public var swift_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var tempFrame: CGRect = frame
            tempFrame.origin.y = newValue
            frame = tempFrame
        }
    }
    
    public var swift_height : CGFloat {
        get {
            return frame.size.height
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.height = newVal
            frame = tmpFrame
        }
    }
    
    
    public var swift_width : CGFloat {
        get {
            return frame.size.width
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.width = newVal
            frame = tmpFrame
        }
    }
    
    public var swift_left : CGFloat {
        get {
            return swift_x
        }
        set(newVal) {
            swift_x = newVal
        }
    }
    
    public var swift_right : CGFloat {
        get {
            return swift_x + swift_width
        }
        set(newVal) {
            swift_x = newVal - swift_width
        }
    }
    
    public var swift_bottom : CGFloat {
        get {
            return swift_y + swift_height
        }
        set(newVal) {
            swift_y = newVal - swift_height
        }
    }
    
    public var swift_centerX : CGFloat {
        get {
            return center.x
        }
        set(newVal) {
            center = CGPoint(x: newVal, y: center.y)
        }
    }
    
    public var swift_centerY : CGFloat {
        get {
            return center.y
        }
        set(newVal) {
            center = CGPoint(x: center.x, y: newVal)
        }
    }
}

//MARK: - 视图层级
extension UIView {
    /// 沿着响应者链找到父视图控制器
    public func getParentVC() -> UIViewController? {
        var next: UIResponder? = self.next
        // 沿着响应者链找到第一个 UIViewController
        while let cur = next, !(cur is UIViewController) { // next 不为空，并且不是 UIViewController 类型的话，就继续
            next = cur.next
        }
        return next as? UIViewController
    }
    
    /// 是否在 window 上显示
    public var isShowingOnKeyWindow: Bool {
        guard let keyWindow = UIApplication.getWindow() else {
            return false
        }
        let frameInSuper = keyWindow.convert(frame, from: superview)
        let intersects = frameInSuper.intersects(keyWindow.bounds)
        return !isHidden && alpha > 0.01 && self.window == keyWindow && intersects
    }
}

