//
//  YJSToast.swift
//  BaseModule
//
//  Created by Admin on 2020/9/3.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

public struct YJSToast {
    // 待展示的内容
    private static var tasks: [ToastTask] = []
    
    public typealias ToastCompletion = () -> ()
    
    /// 使用默认时长，默认高度，展示吐司，吐司消失后不会有回调
    public static func show(_ toast: String?) {
        show(toast, delay: nil, topThanCenter: nil, completion: nil)
    }
    
    /// 使用默认时长，默认高度，展示吐司，吐司消失后调用回调
    public static func show(_ toast: String?, completion: (() -> Void)?) {
        show(toast, delay: nil, topThanCenter: nil, completion: completion)
    }
    
    /// 指定高度，使用默认时长，展示吐司，吐司消失后不会有回调
    public static func show(_ toast: String?, delay: CGFloat) {
        show(toast, delay: delay, topThanCenter: nil, completion: nil)
    }
    
    /// 指定高度，使用默认时长，展示吐司，吐司消失后不会有回调
    public static func show(_ toast: String?, topThanCenter: CGFloat) {
        show(toast, delay: nil, topThanCenter: topThanCenter, completion: nil)
    }
    
    /// 指定高度，指定时长，展示吐司，吐司消失后不会有回调
    public static func show(_ toast: String?, delay: CGFloat?, topThanCenter: CGFloat?, completion: (() -> Void)?) {
        guard let toast = toast else {
            return
        }
        addToastTask(content: toast, duration: delay, topThanCenter: topThanCenter, completion: completion)
    }
        
    private static func p_show(_ toast: String, delay: CGFloat?, completion: ToastCompletion?, topThanCenter: CGFloat?) {
        guard let window = UIApplication.getWindow(), !toast.isEmpty else {
            return
        }
        // 防止意外出现
        existedToast(on: window)?.removeFromSuperview()
        
        let duration = delay ?? 2.0
        let label = YJSToastLabel()
        label.tag = 6783
        label.backgroundColor = Color_HexA(0, alpha: 0.65)
        label.textColor = .white
        label.text = toast.yjs_translateStr()
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = Font_System(15.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingHead
        
        window.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(window.height * 1.0 / 6.0 - (topThanCenter ?? 0))
        }
        
        label.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1) {
            label.transform = CGAffineTransform(scaleX: 1, y: 1)
            label.layoutIfNeeded()
        }
        doAfterInMain(seconds: duration) {
            label.removeFromSuperview()
            completion?()
            doNextToastTask()
        }
    }
}

class YJSToastLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let origin = super.intrinsicContentSize
        return CGSize(width: origin.width + 18, height: origin.height + 18)
    }
}

//MARK: - 解决重叠 toast 问题
extension YJSToast {
    fileprivate struct ToastTask {
        let content: String
        let duration: CGFloat?
        let topThanCenter: CGFloat?
        let completion: YJSToast.ToastCompletion?
    }
    
    // 现在是否可以展示 toast
    fileprivate static func canShowToastNow(onView superView: UIView) -> Bool {
        tasks.count == 0 && existedToast(on: superView) == nil
    }
    
    // 当前视图是否已经有在展示的 toast 了
    fileprivate static func existedToast(on superView: UIView) -> UILabel? {
        superView.subviews.first { (subview) -> Bool in
            subview.tag == 6783 && (subview is UILabel)
        } as? UILabel
    }
    
    // 添加 toast 任务
    static func addToastTask(content: String?, duration: CGFloat?, topThanCenter: CGFloat?, completion: YJSToast.ToastCompletion?, force: Bool = false) {
        guard let content = content else {
            return
        }
        doInMain {
            guard let view = UIApplication.getWindow() else {
                return
            }
            if force {
                tasks.removeAll()
                existedToast(on: view)?.removeFromSuperview()
            }
            if canShowToastNow(onView: view) { // 如果可以直接展示
                p_show(content, delay: duration, completion: completion, topThanCenter: topThanCenter)
            } else {
                let task = ToastTask(content: content, duration: duration, topThanCenter: topThanCenter, completion: completion)
                tasks.append(task)
            }
        }
    }
    
    static func doNextToastTask() {
        guard let task = tasks.first else {
            return
        }
        tasks.removeFirst()
        p_show(task.content,
               delay: task.duration,
               completion: task.completion,
               topThanCenter: task.topThanCenter)
    }
}

//MARK: - 强制展示某个 toast
extension YJSToast {
    /// 指定高度，指定时长，展示吐司，吐司消失后不会有回调
    public static func forceShow(_ toast: String?, delay: CGFloat?, topThanCenter: CGFloat?, completion: (() -> Void)?) {
        guard let toast = toast else {
            return
        }
        addToastTask(content: toast, duration: delay, topThanCenter: topThanCenter, completion: completion, force: true)
    }
}
