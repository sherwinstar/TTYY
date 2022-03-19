//
//  FTZSNavBarView.swift
//  YouShaQi
//
//  Created by Beginner on 2019/9/5.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import CoreGraphics

/*
 YJSNavView 的 top 从 0 像素开始
 contentView：除了返回按钮之外，其他内容都添加到 contentView 上
            它的 top 从 0 像素开始
 */
@objc public final class YJSNavView: UIView, YJSNavProtocol {
    private var style: NavStyle = .white // 导航栏风格
    fileprivate var customColors: YJSNavColors? // 为 h5 专门定义的，指定风格为 customStyle 时有效
        
    public private(set) var rightBtnModels: [YJSNavItemContent]? // 右侧按钮 model
    public var rightHandler: YJSNavBtnHandler?
    public var leftHandler: YJSNavBtnHandler?
    var updateStatusClosure: (() -> ())?
    
    public var leftItemBtn: UIButton? // 返回按钮
    public var titleLabel: UILabel? // 题目
    public var rightBtns: [UIButton]? // 右侧按钮
    public var lineView: UIView? // 底部分隔线
    fileprivate var alphaView: UIView? // 底部分隔线
    
    fileprivate var contentView: UIView? { // 除了返回按钮之外，其他内容都添加到 contentView 上
        style == .webScrollTheme ? alphaView : self
    }
    
    fileprivate var hiddenStatus: Bool = false
    
    fileprivate var isScrollTopClearBgNav: Bool {
        style == .webScrollTheme || style == .webScrollWhite || style == .webScrollDark
    }
    // 针对isScrollTopClearBgNav==true类型有效：alpha是根据页面上滑的距离算出来的，以此来决定导航栏的样式
    fileprivate var lastAlpha: CGFloat = -1
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(title: YJSNavItemContent?, leftBtns: [YJSNavItemContent]?, rightBtns: [YJSNavItemContent]?, handler: (YJSNavBtnHandler)?, config: [YJSNavConfigKey : Any]?) {
        let style: NavStyle = (config?[.navStyle] as? NavStyle) ?? .white
        self.style = style
        self.rightHandler = handler
        
        super.init(frame: .zero)
        
        backgroundColor = isScrollTopClearBgNav ? .clear : style.bgColor(customColors)
        createContentViewIfNeed() // webScrollTheme 类型需要 alphaView，修改 alpha
        title.doIfSome { update(title: $0, config: config) }
        leftBtns.doIfSome { update(btns: $0, isLeft: true, config: config) }
        rightBtns.doIfSome { update(btns: $0, isLeft: false, config: config) }
        didScroll(to: 0)
    }
    
    /// 更新 title
    public func update(title: YJSNavItemContent, config: [YJSNavConfigKey : Any]?) {
        guard let title = title.title else {
            return
        }
        createCenterTitleLabel(title: title)
        updateNav(alpha: lastAlpha)
    }
    
    /// 更新按钮
    public func update(btns: [YJSNavItemContent], isLeft: Bool, config: [YJSNavConfigKey : Any]?) {
        if isLeft {
            btns.first.doIfSome { (model) in
                setupLeftItem(backTitle: model.title, backArrow: model.localImgName != nil)
            }
        } else {
            setupRightBtns(models: btns)
        }
        updateNav(alpha: lastAlpha)
    }
    
    public func showFixedView() {
        updateNav(alpha: 1.0)
    }
}

//MARK: - 左右按钮：左边只支持一个按钮
#if TARGET_ZSSQ
//MARK: 追书返回按钮
extension YJSNavView {
    func setupLeftItem(backTitle: String?, backArrow: Bool) {
        removeOldLeftView()
        createLeftBtn()
        guard let btn = self.leftItemBtn else {
            return
        }
        if style == .webScrollTheme {
            updateThemeScrollBtn(btn)
        } else {
            self.leftItemBtn?.setTitle(backTitle, for: .normal)
            self.leftItemBtn?.setTitleColor(titleColor, for: .normal)
            if backArrow {
                UIImage(named: backImgName).doIfSome { (img) in
                    self.leftItemBtn?.setImage(img, for: .normal)
                }
            } else {
                self.leftItemBtn?.setImage(nil, for: .normal)
            }
            self.leftItemBtn?.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.centerY.equalToSuperview().offset(Screen_NavItemY / 2.0)
            }
        }
        updateTitleLabelPosition()
    }
    
    private func updateThemeScrollBtn(_ btn: UIButton) {
        btn.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        UIImage(named: backImgName).doIfSome { (img) in
            btn.setImage(img, for: .normal)
        }
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        btn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 34, height: 34))
            make.centerY.equalToSuperview().offset(Screen_NavItemY / 2.0)
        }
    }
}
#else
//MARK: 饭团返回按钮
extension YJSNavView {
    func setupLeftItem(backTitle: String?, backArrow: Bool) {
        removeOldLeftView()
        createLeftBtn()
        guard let btn = self.leftItemBtn else {
            return
        }
        if style == .webScrollTheme {
            updateThemeScrollBtn(btn)
        } else {
            let title = backTitle ?? ""
            if (backArrow) {
                self.leftItemBtn?.setTitle(title, for: .normal)
                self.leftItemBtn?.setImage(UIImage(named: backImgName), for: .normal)
            } else {
                self.leftItemBtn?.setTitle(title, for: .normal)
            }
            self.leftItemBtn?.setTitleColor(self.btnNormalColor, for: .normal)
            self.leftItemBtn?.snp.makeConstraints { (make) in
                make.top.equalTo(self).offset(Screen_NavItemY);
                make.left.equalTo(self).offset(Screen_IPadMultiply(15));
                make.bottom.equalTo(self);
            }
        }
        updateTitleLabelPosition()
    }
    
    private func updateThemeScrollBtn(_ btn: UIButton) {
        btn.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        UIImage(named: backImgName).doIfSome { (img) in
            btn.setImage(img, for: .normal)
        }
        btn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.centerY.equalToSuperview().offset(Screen_NavItemY / 2.0)
        }
    }
}
#endif

//MARK: - 右侧按钮
extension YJSNavView {
    private func setupRightBtns(models: [YJSNavItemContent]) {
        hideOldRightViews()
        rightBtnModels = models
        let btns = models.iMap { (model, i) -> UIButton in
            let btn: UIButton
            let index: Int = model.identifier.flatMap({ Int($0) }) ?? i
            if let title = model.title {
                btn = createRightTitleBtn(title, index: index)
            } else if let img = model.localImgName {
                btn = createRightImgBtn(img, img, index: index)
            } else {
                btn = createRightTitleBtn("", index: index)
            }
            return btn
        }
        rightBtns = btns
        updateRightBtnPosition()
        updateTitleLabelPosition()
    }
    
    fileprivate func didClickLeftBtn() {
        self.leftHandler?(0)
    }
    
    private func didClickRightBtn(_ index: Int) {
        self.rightHandler?(index)
    }
}

//MARK: - 更新主题
extension YJSNavView {
    public func update(titleColor: UIColor?, bgColor: UIColor?, isRedBack: Bool) {
        guard let colors = YJSNavColors.from(btnColor: titleColor, titleColor: titleColor, bgColor: bgColor, isRedBack: isRedBack) else {
            return
        }
        self.style = .customStyle
        self.customColors = colors
        updateStyle()
    }
    
    private func updateStyle() {
        // title
        self.titleLabel?.textColor = titleColor
        // 右边按钮
        self.rightBtns?.forEach({ (btn) in
            btn.setTitleColor(btnNormalColor, for: .normal)
        })
        // 返回按钮
        setupLeftItem(backTitle: leftItemBtn?.title(for: .normal), backArrow: true)
        // 背景色
        self.backgroundColor = self.bgColor
        updateNav(alpha: lastAlpha)
    }
}

//MARK: - 滑动导航栏
extension YJSNavView {
    public func didScroll(to offsetY: CGFloat) {
        guard isScrollTopClearBgNav else {
            return
        }
        // 根据 offsetY 获取到 alpha
        var alpha = getAlpha(offset: offsetY)
        // webScrollWhite 的 alpha 只有 0/1，没有中间过渡
        if style.isWebScrollWhiteKind {
            alpha = alpha > 0.3 ? 1.0 : 0
        }
        if alpha == lastAlpha {
            return
        }
        updateNav(alpha: alpha)
    }
    
    fileprivate func updateNav(alpha: CGFloat) {
        guard isScrollTopClearBgNav, alpha >= 0 else {
            return
        }
        lastAlpha = alpha
        // 当 alpha 过渡到 1/0，电池条显示状态也要改变
        if alpha == 1.0 {
            changeStatus(hidden: false)
        } else if alpha == 0 {
            changeStatus(hidden: true)
        }
        // 按钮/背景色等，跟着 alpha 改变
        alphaView?.alpha = alpha
        if style == .webScrollTheme { // 按钮背景色改变
            let btnAlpha = (1.0 - alpha) * 0.5
            leftItemBtn?.backgroundColor = UIColor(white: 0.5, alpha: btnAlpha)
            rightBtns?.doIn({ (btn) in
                btn.backgroundColor = UIColor(white: 0.5, alpha: btnAlpha)
            })
        } else if style.isWebScrollWhiteKind { // 按钮图片改变
            let isTop = alpha != 1.0
            contentView?.backgroundColor = isTop ? .clear : bgColor
            let isWhite = isTop && style == .webScrollWhite
            let textColor = isWhite ? .white : titleColor
            titleLabel?.textColor = textColor
            #if TARGET_ZSSQ
            let backImgName = isWhite ? "nav_left_white" : style.backImgName()
            #else
            let backImgName = "nav_back"// isWhite ? "nav_left_white" : style.backImgName()
            #endif
            let originImg = UIImage(named: backImgName)
            let backImg = originImg?.yjs_image(tintColor: textColor)
            leftItemBtn?.setImage(backImg, for: .normal)
            leftItemBtn?.setTitleColor(textColor, for: .normal)
            self.rightBtns?.doIn({ (btn) in
                btn.setTitleColor(textColor, for: .normal)
                btn.setTitleColor(textColor, for: .highlighted)
            })
//            let backImgName = isWhite ? "nav_left_white" : style.backImgName()
//            leftItemBtn?.setImage(UIImage(named: backImgName), for: .normal)
        }
    }
    
    private func getAlpha(offset: CGFloat) -> CGFloat {
        let topMargin = Screen_SafeTopHeight
        var alpha: CGFloat = 0.0
        if offset + topMargin > Screen_NavHeight {
            alpha = min(1.0, abs(offset + topMargin - Screen_NavHeight) / Screen_NavHeight)
        }
        return alpha
    }
    
    private func changeStatus(hidden: Bool) {
        if hiddenStatus != hidden {
            hiddenStatus = hidden
            updateStatusClosure?()
        }
    }
    
    public var prefersStatusBarHidden: Bool? {
        isScrollTopClearBgNav ? hiddenStatus : false
    }
    
    public var preferredStatusBarStyle: UIStatusBarStyle? {
        style.preferredStatusBarStyle(customColors)
    }
    
    public var isOverlayContent: Bool {
        style.isOverlayContent
    }
}

//MARK: - 创建子视图
extension YJSNavView {
    private func createContentViewIfNeed() {
        if style == .webScrollTheme && contentView == nil {
            let view = UIView()
            view.backgroundColor = bgColor
            alphaView = view
            alphaView?.alpha = 0
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    fileprivate func createLeftBtn() {
        let btn = UIButton()
        btn.titleLabel?.font = Font_System(16)
        addSubview(btn)
        btn.rx.tap.bind(onNext: { [weak self] (_) in
            self?.didClickLeftBtn()
        }).disposed(by: disposeBag)
        leftItemBtn = btn
    }
    
    fileprivate func createCenterTitleLabel(title: String) {
        let label = self.titleLabel ?? UILabel()
        if (self.titleLabel == nil) {
            self.titleLabel = label
            contentView?.addSubview(label)
            updateTitleLabelPosition()
        }
        label.font = Font_Medium(18)
        label.textAlignment = .center
        label.text = title
        label.textColor = titleColor
    }
        
    fileprivate func createRightTitleBtn(_ title: String, index: Int) -> UIButton {
        let btn = UIButton()
        if style == .webScrollTheme {
            btn.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            btn.layer.cornerRadius = 16
            btn.layer.masksToBounds = true
        }
        let titleSize: CGSize = calculateSize(str: title, font: Font_System(16))
        let width = max(titleSize.width + 30, 44)
        btn.swift_width = width
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(btnNormalColor, for: .normal)
        btn.titleLabel?.font = Font_System(16)
        self.addSubview(btn)
        btn.rx.tap.bind(onNext: { [weak self] (_) in
            self?.didClickRightBtn(index)
        }).disposed(by: disposeBag)
        return btn
    }
    
    fileprivate func createRightImgBtn(_ normal: String, _ highlight: String, index: Int) -> UIButton {
        let btn = UIButton()
        if style == .webScrollTheme {
            btn.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            btn.layer.cornerRadius = 16
            btn.layer.masksToBounds = true
        }
        let normalImg = UIImage(named: normal)
        let highImg = UIImage(named: highlight)
        let width = max(normalImg?.size.width ?? 44, 44)
        btn.swift_width = width
        btn.setImage(normalImg, for: .normal)
        self.addSubview(btn)
        btn.rx.tap.bind(onNext: { [weak self] (_) in
            self?.didClickRightBtn(index)
        }).disposed(by: disposeBag)
        return btn
    }
    
    fileprivate func updateRightBtnPosition() {
        guard let btns = rightBtns, let lastBtn = btns.last else {
            return
        }
        // 确定按钮宽度
        let widths = btns.map { (btn) -> CGFloat in
            btn.swift_width
        }
        let btnMaxWidth = style == .webScrollTheme ? 32 : (widths.max() ?? 44)
        let lastRight = style == .webScrollTheme ? 15 : 10
        // 设置按钮位置
        var preBtn: UIButton?
        for cur in btns {
            let isLast = (cur == lastBtn)
            cur.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: btnMaxWidth, height: btnMaxWidth))
                make.centerY.equalToSuperview().offset(Screen_NavItemY / 2.0)
                if (isLast) {
                    make.right.equalTo(self.snp_right).offset(-lastRight);
                }
                if let pre = preBtn {
                    make.left.equalTo(pre.snp_right);
                }
                preBtn = cur
            })
        }
    }
    
    fileprivate func updateTitleLabelPosition() {
        self.titleLabel?.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(Screen_NavItemY);
            make.bottom.equalTo(self);
            if let left = leftItemBtn {
                make.left.greaterThanOrEqualTo(left.snp_right)
            }
            if let right = rightBtns?.first {
                make.right.lessThanOrEqualTo(right.snp_left)
            }
        })
        self.titleLabel?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    fileprivate func createBottomLine() {
        if self.lineView == nil {
            let line = UIView()
            line.backgroundColor = self.lineColor;
            contentView?.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.left.right.equalTo(self);
                make.height.equalTo(0.5);
                make.bottom.equalTo(self).offset(-0.5);
            }
            self.lineView = line
        }
    }
        
    //MARK: - 移除旧的View
    fileprivate func removeOldCenterView(_ removed: UIView?) {
        if let label = self.titleLabel, self.titleLabel == removed {
            label.isHidden = true
        }
    }
    
    fileprivate func removeOldLeftView() {
        leftItemBtn?.removeFromSuperview()
        leftItemBtn = nil
    }
    
    fileprivate func hideOldRightViews() {
        guard let btns = rightBtns else {
            return
        }
        for btn in btns {
            btn.removeFromSuperview()
        }
        rightBtns?.removeAll()
    }
    
    fileprivate func calculateSize(str: String, font: UIFont) -> CGSize {
        let rect = (str as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
    
    func updateNavBottomLineColor(color: UIColor) {
        self.lineView?.backgroundColor = color
    }
    
    ///是否需要显示导航栏底部分割线 默认NO
    fileprivate func needShowNavBarBottomLine(showLine: Bool) {
        if (showLine) {
            createBottomLine()
        } else {
            self.lineView?.removeFromSuperview()
            self.lineView = nil
        }
    }
}

//MARK: - 样式
extension YJSNavView {
    static let BarRightBtnBaseTag = 20190304
    
    var bgColor: UIColor {
        style.bgColor(customColors)
    }
    var titleColor: UIColor {
        style.titleColor(customColors)
    }
    var lineColor: UIColor {
        style.lineColor(customColors)
    }
    var btnNormalColor: UIColor {
        style.btnNormalColor(customColors)
    }
    var btnHighlightColor: UIColor {
        style.btnHighlightColor(customColors)
    }
    var backImgName: String {
        style.backImgName(customColors)
    }
    
    struct YJSNavColors {
        let bgColor: UIColor
        let titleColor: UIColor
        let lineColor: UIColor
        let btnNormalColor: UIColor
        let btnHighlightColor: UIColor
        let isRedBack: Bool
        
        static func from(btnColor: UIColor?, titleColor: UIColor?, bgColor: UIColor?, isRedBack: Bool) -> YJSNavColors? {
            guard let btnColor = btnColor, let titleColor = titleColor, let bgColor = bgColor else {
                return nil
            }
            let colors = YJSNavColors(bgColor: bgColor, titleColor: titleColor, lineColor: bgColor, btnNormalColor: btnColor, btnHighlightColor: btnColor, isRedBack: isRedBack)
            return colors
        }
    }
    
    @objc public enum NavStyle: Int {
        case white
        case theme // 主题色，追书中是红色
        case clear //透明
        // webScrollTheme 与 webScrollWhite 返回按钮图片不同、背景色不同、电池条颜色不同、滑动之后的响应也不同
        // 第一个版本：内容滑动到顶部时就背景色透明，按钮都显示，但是都有个半透明灰色的背景色； 内容向下滑动之后，导航栏显示红色的背景色，按钮也都显示，但是透明色背景色的按钮；
        // 第二个版本：webScrollTheme -> 浅色模式，webScrollWhite -> 深色模式，浅色/深色模式，内容滑到顶部时，背景色都是透明的，题目/按钮颜色分别是白色和黑色，内容向下划动之后，导航栏背景色白色，题目/按钮黑色
        case webScrollTheme
        case webScrollWhite // 内容滑动到顶部时就背景色透明，按钮都显示，按钮没有背景色； 内容向下滑动之后，导航栏显示白色的背景色，按钮也都显示；
        case webScrollDark
        case customStyle // 自定义主题色，应该把主题色model作为关联值的，但是那样做了的话，NavStyle就不能声明成@objc了
        
        fileprivate var isOverlayContent: Bool {
            switch self {
            case .white, .theme, .customStyle:
                return false
            case .clear, .webScrollTheme, .webScrollWhite, .webScrollDark:
                return true
            }
        }
        
        fileprivate var isWebScrollWhiteKind: Bool {
            return self == .webScrollDark || self == .webScrollWhite
        }
        
        fileprivate func bgColor(_ theme: YJSNavColors? = nil) -> UIColor {
            switch self {
            case .white, .webScrollWhite, .webScrollDark:
                return .white
            case .theme, .webScrollTheme:
                return Color_Theme
            case .clear:
                return .clear
            case .customStyle: // 默认跟 .white 一样
                return theme?.bgColor ?? .white
            }
        }
        fileprivate func titleColor(_ theme: YJSNavColors? = nil) -> UIColor {
            switch self {
            case .white, .webScrollWhite, .webScrollDark:
                #if TARGET_ZSSQ
                return Color_Hex(0x262626)
                #else
                return Color_Hex(0x111111)
                #endif
            case .theme, .webScrollTheme:
                return .white
            case .clear:
                return .white
            case .customStyle: // 默认跟 .white 一样
                return theme?.titleColor ?? .black
            }
        }
        fileprivate func lineColor(_ theme: YJSNavColors? = nil) -> UIColor {
            switch self {
            case .white, .webScrollWhite, .webScrollDark:
                return Color_RGB(170, 170, 170)
            case .theme, .webScrollTheme:
                return Color_RGB(133, 11, 11)
            case .clear:
                return Color_RGB(133, 11, 11)
            case .customStyle: // 默认跟 .white 一样
                return theme?.bgColor ?? Color_RGB(170, 170, 170)
            }
        }
        fileprivate func btnNormalColor(_ theme: YJSNavColors? = nil) -> UIColor {
            switch self {
            case .white:
                #if TARGET_ZSSQ
                return Color_Hex(0x262626)
                #else
                return .black
                #endif
            case .theme, .webScrollTheme, .clear:
                return .white
            case .webScrollWhite, .webScrollDark:
                #if TARGET_ZSSQ
                return Color_Hex(0x262626)
                #else
                return .black
                #endif
            case .customStyle: // 默认跟 .white 一样
                return theme?.bgColor ?? Color_Theme
            }
        }
        fileprivate func btnHighlightColor(_ theme: YJSNavColors? = nil) -> UIColor {
            switch self {
            case .white:
                #if TARGET_ZSSQ
                return Color_Hex(0x262626)
                #else
                return .black
                #endif
            case .theme, .webScrollTheme, .clear:
                return .white
            case .webScrollWhite, .webScrollDark:
                #if TARGET_ZSSQ
                return Color_Hex(0x262626)
                #else
                return .black
                #endif
            case .customStyle: // 默认跟 .white 一样
                return theme?.bgColor ?? Color_Theme
            }
        }
        fileprivate func backImgName(_ theme: YJSNavColors? = nil) -> String {
            #if TARGET_ZSSQ
            switch self {
            case .theme, .clear:
                return "nav_left_white"
            case .white:
                return "nav_left_black"
            case .customStyle: // 默认跟 .white 一样
                return (theme?.isRedBack) ?? false ? "nav_left_black" : "nav_left_white"
            case .webScrollTheme:
                return "nav_left_white"
            case .webScrollWhite, .webScrollDark:
                return "nav_left_black"
            }
            #else
            switch self {
            case .theme:
                return "nav_back_white"
            case .clear:
                return "nav_back_white_clear"
            case .white:
                return "nav_back"
            case .customStyle: // 默认跟 .white 一样
                return (theme?.isRedBack) ?? false ? "nav_back" : "nav_back_white"
            case .webScrollTheme:
                return "nav_back_white"
            case .webScrollWhite, .webScrollDark:
                return "nav_back"
            }
            #endif

        }
        fileprivate func preferredStatusBarStyle(_ theme: YJSNavColors? = nil) -> UIStatusBarStyle {
            switch self {
            case .theme, .clear, .webScrollTheme:
                return .lightContent
            case .white, .webScrollWhite, .webScrollDark:
                return .default
            case .customStyle:
                return theme?.isRedBack ?? false ? .default : .lightContent
            }
        }
    }
}

extension YJSNavConfigKey {
    public static var navStyle = YJSNavConfigKey(rawValue: "navStyle")
    // 当导航栏在顶部的时候透明背景色，所有的右边按钮都不显示
    public static var isScrollTopClearBgNav = YJSNavConfigKey(rawValue: "isScrollTopClearBgNav")
}
