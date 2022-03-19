//
//  YJSCustomProgress.swift
//  BaseModule
//
//  Created by Admin on 2020/9/3.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import SnapKit
import MBProgressHUD

//MARK: - 协议
@objc public protocol YJSProgressOwnerProtocol: NSObjectProtocol {
    var progressSuperView: UIView? { get }
    @objc var progress: MBProgressHUD? { get set }
    @objc optional func progressFrame() -> CGRect
    @objc optional func hudDidClicked()
    @objc optional func isNightStyle() -> Bool
    @objc optional func isReaderStyle() -> Bool
}

extension NSObject: YJSProgressOwnerProtocol {
    @objc open var progressSuperView: UIView? {
        UIApplication.getWindow()
    }
    
    private static var progressKey: String = "nsobject.progress"
    @objc public var progress: MBProgressHUD? {
        get {
            return objc_getAssociatedObject(self, &(UIView.progressKey)) as? MBProgressHUD
        }
        set {
            objc_setAssociatedObject(self, &(UIView.progressKey), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc open func hudDidClicked() {
        
    }
    // 展示默认的progress
    @objc public func showProgress() {
        MBProgressHUD.show(on: progressSuperView, delegate: self)
    }
    
    // 展示内购样式的progress
    @objc public func showIapProgress(msg: String?) {
        MBProgressHUD.showInIap(msg: msg, delegate: self)
    }
    
    // 可以响应点击事件的progress，只有在阅读器初始化时会用到，一定要重写 hudDidClicked
    @objc public func showInteractiveProgress() {
        MBProgressHUD.showInteractive(inReader: progressSuperView, delegate: self)
    }
    
    // 隐藏 progress
    @objc public func hideProgress() {
        MBProgressHUD.hide(delegate: self)
    }
    
    // 隐藏 progress
    @objc public func hideProgressLater() {
        MBProgressHUD.hideLater(delegate: self)
    }
    
    // 收起 progress，并且如果有 msg 就展示结束语
    @objc public func hideProgress(msg: String?) {
        MBProgressHUD.hide(delegate: self)
        if let m = msg, !m.isEmpty {
            YJSToast.show(m)
        }
    }
    
    // 收起 progress，并且如果有 msg 就展示结束语 duration 秒钟，duration 为0就使用默认值
    @objc public func hideProgress(msg: String?, duration: CGFloat) {
        MBProgressHUD.hide(delegate: self)
        if let m = msg {
            if duration > 0 {
                YJSToast.show(m, delay: duration)
            } else {
                YJSToast.show(m)
            }
        }
    }
    
    @objc public func hideProgress(msg: String?, duration: CGFloat, delay: CGFloat) {
        if delay > 0 {
            doAfterInMain(seconds: delay) {
                self.hideProgress(msg: msg, duration: duration)
            }
        } else {
            hideProgress(msg: msg, duration: duration)
        }
    }
    
    // 更新内购 progress 文字
    @objc public func updateIap(msg: String?) {
        if let m = msg {
            MBProgressHUD.updateIap(msg: msg, delegate: self)
        }
    }
    
    // 展示图片 progress，书籍详情页添加书籍/删除书籍时用到了
    @objc public func showImgProgress(msg: String?, imgName: String) {
        MBProgressHUD.show(on: progressSuperView, delegate: self, msg: msg, imgName: imgName)
    }
    
    // 更新图片 progress
    @objc public func updateImgProgress(msg: String?, imgName: String) {
        MBProgressHUD.update(msg: msg, imgName: imgName, delegate: self)
    }
    
    @objc public func showToast(msg: String?) {
        MBProgressHUD.hide(delegate: self)
        if let m = msg {
            YJSToast.show(m, delay: 1.5)
        }
    }
    
    // 展示吐司
    @objc public func showToast(msg: String?, duration: CGFloat) {
        MBProgressHUD.hide(delegate: self)
        if let m = msg {
            YJSToast.show(m, delay: duration)
        }
    }
    
    // 当前视图控制器是否在展示 progress
    @objc public func isShowingProgress() -> Bool {
        if let p = progress, let _ = p.superview, !p.isHidden {
            return true
        }
        return false
    }
    
    @objc public func showProgressInWindow() {
        MBProgressHUD.show(on: UIApplication.getWindow(), delegate: self)
    }
}

//MARK: - View 扩展
extension UIView {
    @objc open override var progressSuperView: UIView? {
        self
    }
}

//MARK: - VC 扩展
extension UIViewController {
    @objc open override var progressSuperView: UIView? {
        view
    }
}

//MARK: - MBProgressHUD 扩展
//MARK: 隐藏
public extension MBProgressHUD {
    @objc public static func hideLater(delegate: YJSProgressOwnerProtocol) {
        hide(delegate: delegate, delay: 0.5)
    }
    
    @objc public static func hide(delegate: YJSProgressOwnerProtocol) {
        hide(delegate: delegate, delay: 0)
    }
    
    @objc public static func hide(delegate: YJSProgressOwnerProtocol, delay: CGFloat) {
        if delay > 0 {
            doAfterInMain(seconds: delay) {
                removeProgress(delegate: delegate)
            }
        } else {
            performUI {
                removeProgress(delegate: delegate)
            }
        }
    }
}

//MARK: 默认的 progress
extension MBProgressHUD {
    @objc public static func show(on superView: UIView?, delegate: YJSProgressOwnerProtocol) {
        guard let superView = superView else {
            return
        }
        performUI {
            removeProgress(delegate: delegate)
            let progress = createProgress(on: superView, delegate: delegate)
            progress?.show(animated: true)
        }
    }
    
    private static func createProgress(on superView: UIView?,
                                       delegate: YJSProgressOwnerProtocol) -> MBProgressHUD? {
        guard let superView = superView else {
            return nil
        }
        let progress = MBProgressHUD(view: superView)
        progress.layer.zPosition = CGFloat(Int.max)
        progress.mode = .customView
        progress.removeFromSuperViewOnHide = true
        superView.addSubview(progress)
        progress.delegate = delegate as? MBProgressHUDDelegate
        delegate.progress = progress
        if let frame = delegate.progressFrame?() {
            progress.frame = frame
        }
        let img = Bundle.main.url(forResource: "loading", withExtension: "gif")
            .flatMap { try? Data.init(contentsOf: $0) }
            .flatMap { UIImage.sd_animatedGIF(with: $0) }
        let imgView = UIImageView.init(image: img)
        imgView.snp.makeConstraints { (make) in
            #if TARGET_ZSSQ
            make.size.equalTo(CGSize(width: 33, height: 33))
            #elseif TARGET_TTYY
            make.size.equalTo(CGSize(width: 30, height: 30))
            #else
            make.size.equalTo(CGSize(width: 60, height: 60))
            #endif
        }
        progress.customView = imgView
        
        progress.backgroundView.color = .clear
        // 设置毛玻璃效果
        if delegate.isNightStyle?() ?? false {
            if delegate.isReaderStyle?() ?? false {
                #if TARGET_FTZS
                progress.bezelView.color = .clear
                progress.bezelView.style = .solidColor
                progress.customView?.alpha = 0.6
                #else
                progress.bezelView.color = Color_HexA(0x5C5A5D, alpha: 0.8)
                progress.bezelView.style = .solidColor
                let maskView = UIView()
                maskView.backgroundColor = .black
                maskView.alpha = 0.4
                progress.bezelView.addSubview(maskView)
                maskView.isUserInteractionEnabled = false
                maskView.snp.makeConstraints { (make) in
                    make.top.left.right.bottom.equalTo(progress.bezelView);
                }
                #endif
            } else {
                progress.bezelView.color = .clear
                progress.bezelView.style = .solidColor
            }
        } else {
            #if TARGET_FTZS
            progress.bezelView.color = .clear
            progress.bezelView.style = .solidColor
            #else
            progress.bezelView.color = Color_RGBA(255, 255, 255, 0.9)
            progress.bezelView.style = .blur
            progress.bezelView.blurEffectStyle = .light
            #endif
        }
        return progress
    }
}

//MARK: 阅读器初始化时的 progress（可点击）
extension MBProgressHUD {
    @objc public static func showInteractive(inReader superView: UIView?, delegate: YJSProgressOwnerProtocol) {
        guard let superView = superView else {
            return
        }
        performUI {
            removeProgress(delegate: delegate)
            guard let progress = createProgress(on: superView, delegate: delegate) else {
                return
            }
            let selector = NSSelectorFromString("hudDidClicked")
            if delegate.responds(to: selector) {
                let tap = UITapGestureRecognizer(target: delegate, action: selector)
                progress.addGestureRecognizer(tap)
            }
            progress.show(animated: false)
        }
    }
}

//MARK: 内购 progress：有提示文字
extension MBProgressHUD {
    @objc public static func showInIap(msg: String?, delegate: YJSProgressOwnerProtocol) {
        performUI {
            removeProgress(delegate: delegate)
            let progress = MBProgressHUD()
            progress.label.text = (msg ?? "加载中").yjs_translateStr()
            defaultSuperView()?.addSubview(progress)
            delegate.progress = progress
            progress.show(animated: true)
        }
    }
    
    @objc public static func updateIap(msg: String?, delegate: YJSProgressOwnerProtocol) {
        performUI {
            if let progress = delegate.progress {
                progress.label.text = msg
            } else {
                showInIap(msg: msg, delegate: delegate)
            }
        }
    }
}

//MARK: 图片的 progress
extension MBProgressHUD {
    @objc public static func show(on superView: UIView?, delegate: YJSProgressOwnerProtocol, msg: String?, imgName: String) {
        guard let superView = superView else {
            return
        }
        performUI {
            removeProgress(delegate: delegate)
            let progress = MBProgressHUD()
            progress.label.text = msg
            let imgView = UIImageView(image: UIImage.init(named: imgName))
            imgView.tag = 513 // 5月13号写的代码，纪念一下
            imgView.bounds = CGRect(x: 0, y: 0, width: 37, height: 37)
            progress.customView = imgView
            progress.mode = .customView
            progress.alpha = 0.9
            superView.addSubview(progress)
            delegate.progress = progress
            progress.show(animated: true)
        }
    }
    
    @objc public static func update(msg: String?, imgName: String, delegate: YJSProgressOwnerProtocol) {
        performUI {
            delegate.progress?.label.text = msg
            if let imgView = delegate.progress?.viewWithTag(513) as? UIImageView {
                imgView.image = UIImage(named: imgName)
            }
        }
    }
}

//MARK: private
extension MBProgressHUD {
    private static func performUI(_ closure: @escaping () -> ()) {
        if Thread.isMainThread {
            closure()
        } else {
            doInMain(closure)
        }
    }
    
    private static func removeProgress(delegate: YJSProgressOwnerProtocol) {
        guard let progress = delegate.progress as? MBProgressHUD else { return }
        progress.hide(animated: false)
        progress.removeFromSuperview()
        delegate.progress = nil
    }
    
    private static func defaultSuperView() -> UIView? {
        UIApplication.getWindow()
    }
}

