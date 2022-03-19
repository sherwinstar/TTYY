//
//  YJSBaseVC.swift
//  YouShaQi
//
//  Created by Beginner on 2019/7/30.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import SnapKit

@objc public protocol YJSVCWillDisappearObserver {
    @objc optional func delayShowNextVC(_ nextVC: UIViewController) -> CGFloat
}

public protocol YJSTabbarVCProtocol: NSObjectProtocol {
    var isTabBarShow: Bool { get set }
}

@objc(YJSBaseVC)
open class YJSBaseVC: UIViewController {
    open var protocolNav: YJSNavProtocol? // 真正的导航栏
    // 把protocolNav转成 View，因为YJSNavProtocol没办法声明成@objc
    @objc public var navView: UIView? { protocolNav ?? nil }
    @objc public var navType: NavType = .normal // 导航栏类型
    
    @objc public var backGestureEnabled: Bool = true // 是否允许侧滑返回
    @objc public var edgeGestureEnabled: Bool = false // 是否限制滑动开始的位置x<50，默认不限制，目前只有web页需要
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let count = self.navigationController?.viewControllers.count
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (count! > 1)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .white
    }
    
    // 通过测滑取消 loading 时的回调，可以做些回收工作
    open func viewDidRemoveByBackGesture() {
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabbarView()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabbarView()
    }
    
    private func hideTabbarView() {
        if let tabbarVC = self.navigationController?.parent as? YJSTabbarVCProtocol {
            tabbarVC.isTabBarShow = (self.navigationController?.viewControllers.count ?? 0) == 1
        }
    }
}

//MARK: - 导航栏类型定义
extension YJSBaseVC {
    @objc public enum NavType: Int {
        case normal // 默认的导航栏
        case hidden // 不展示导航栏
        case custom // 自定义的导航栏，必须实现 YJSNavProtocol
    }
}

//MARK: - 默认类型初始化
extension YJSBaseVC {
    fileprivate var navBarView: YJSNavView? {
        navView as? YJSNavView
    }
    
    //MARK: 初始化导航栏
    // 初始化默认类型的导航栏
    public func setupNavBar(style: YJSNavView.NavStyle = .white, title: String? = nil, titleImgName: String? = nil, defaultBack: Bool = true) {
        navType = .normal
        let titleContent = YJSNavItemContent(title: title, localImgName: titleImgName, netImgUrl: nil, identifier: nil)
        let nav = YJSNavView(title: titleContent, leftBtns: nil, rightBtns: nil, handler: nil, config: [.navStyle : style])
        nav.updateStatusClosure = { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        protocolNav = nav
        if let nav = navBarView {
            view.addSubview(nav)
            attachNav()
        }
        if defaultBack {
            if style == .clear {
                setupLeftItem(backArrow: true)
            } else {
                setupLeftItem()
            }
        }
        setDefaultLeftHandler()
    }
    
    /// 更新题目
    public func updateTitle(_ title: String?) {
        let content = YJSNavItemContent(title: title)
        protocolNav?.update(title: content, config: nil)
    }
    
    /// 返回按钮
    public func setupLeftItem(backTitle: String? = nil, backArrow: Bool = true) {
        var title = backTitle
        #if TARGET_FTZS
        title = title ?? "返回"
        #endif
        let localImgName = backArrow ? "" : nil
        let backBtn = YJSNavItemContent(title: title, localImgName: localImgName, netImgUrl: nil, identifier: nil)
        protocolNav?.update(btns: [backBtn], isLeft: true, config: nil)
    }

    
    /// 如果左侧按钮的事件需要自定义的话，就重写这个方法，重写方法中也要处理返回，返回可以直接调用 hideSelf()
    /// - Parameter index: 这个参数可以忽视
    /// - Returns: 如果是重写的方法，要返回 true，这样才不会重复调用 hideSelf 方法
    @objc open func onLeftClicked(at index: Int) -> Bool {
        false
    }
    
    /// 导航栏右侧按钮
    public func setupRightBarItems(imgs: [String]) {
        let btnModels = imgs.map { (img) in
            YJSNavItemContent(localImgName: img)
        }
        protocolNav?.update(btns: btnModels, isLeft: false, config: nil)
        protocolNav?.updateRight(btnAction: { [weak self] (i) in
            self?.onRightClicked(at: i)
        })
    }
    
    ///导航右侧为文字
    public func setupRightBarItems(titles: [String]) {
        let btnModels = titles.map { (title) in
            YJSNavItemContent(title: title)
        }
        protocolNav?.update(btns: btnModels, isLeft: false, config: nil)
        protocolNav?.updateRight(btnAction: { [weak self] (i) in
            self?.onRightClicked(at: i)
        })
    }
    
    public func setupRightBarItems(navItems: [YJSNavItemContent]) {
        protocolNav?.update(btns: navItems, isLeft: false, config: nil)
        protocolNav?.updateRight(btnAction: { [weak self] (i) in
            self?.onRightClicked(at: i)
        })
    }
    
    // 如果右侧有按钮，需要被重写
    @objc open func onRightClicked(at index: Int) {
        
    }
    
    /// 更新样式
    public func updateStyle(titleColor: UIColor?, bgColor: UIColor?, isRedBack: Bool) {
        navBarView?.update(titleColor: titleColor, bgColor: bgColor, isRedBack: isRedBack)
    }
    
    public func getRightBtn(at index: Int, _ closure: (UIButton) -> ()) {
        guard let btn = protocolNav?.getRightBtn(at: index) else {
            return
        }
        closure(btn)
    }
    
    private func setDefaultLeftHandler() {
        protocolNav?.updateLeft(btnAction: { [weak self] (i) in
            guard let sSelf = self else {
                return
            }
            if !sSelf.onLeftClicked(at: i) {
                sSelf.hideSelf()
            }
        })
    }
}

//MARK: - 其他类型导航栏初始化
extension YJSBaseVC {
    public func setupHiddenNav() {
        navType = .hidden
    }
    
    public func setupCustomNav(_ nav: YJSNavProtocol) {
        navType = .custom
        view.addSubview(nav)
        protocolNav = nav
        attachNav()
        setDefaultLeftHandler()
    }
}

//MARK: - 其他导航栏方法
extension YJSBaseVC {
    public func addViewBelowNav(_ subview: UIView) {
        if let nav = protocolNav {
            view.insertSubview(subview, belowSubview: nav)
        } else {
            view.addSubview(subview)
        }
    }
    
    public func attachToTop(_ view: UIView, by make: ConstraintMaker) {
        if !(protocolNav?.isOverlayContent ?? true), let bottom = navView?.snp_bottom {
            make.top.equalTo(bottom)
        } else {
            make.top.equalTo(view.snp_top)
        }
    }
    
    public func attachNav() {
        protocolNav.doIfSome { (nav) in
            view.bringSubviewToFront(nav)
            nav.snp.makeConstraints { (make) in
                make.left.right.top.equalTo(self.view)
                make.height.equalTo(nav.navHeight)
            }
        }
    }
}

//MARK: - 横竖屏
extension YJSBaseVC {
    @objc open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @objc open override var shouldAutorotate: Bool {
        return false
    }
}

//MARK: - 重写 present 方法以适配阅读器横屏
extension YJSBaseVC {
    @objc open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if !viewControllerToPresent.isKind(of: UIAlertController.self),
            let observer = self as? YJSVCWillDisappearObserver,
            let delay = observer.delayShowNextVC?(viewControllerToPresent),
            delay > 0 {
            doAfterInMain(seconds: delay) {
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

//MARK: - 电池条
extension YJSBaseVC {
    /*
     因为在询问电池条状态时，protocolNav 还没有赋值，所以返回的都是默认值
     如果需要更新的话，要在调用 setupNav 之后调用 setNeedsStatusBarAppearanceUpdate()
     */
    open override var prefersStatusBarHidden: Bool {
        protocolNav?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        protocolNav?.preferredStatusBarStyle ?? .default
    }
}

//MARK: - 方便方法
extension YJSBaseVC {
    public func hideSelf() {
        if let nav = self.navigationController, nav.viewControllers.last == self {
            if nav.viewControllers.count == 1, let _ = nav.presentingViewController {
                self.dismiss(animated: true, completion: nil)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
