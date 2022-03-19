//
//  YJSWebStoreVC.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/4.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import BaseModule

/*
 网页的导航栏有4种样式：
 1. 默认样式：固定的导航栏
    由 BaseVC 的 YJSNavView 实现
    navType = .normal（默认就是这样，不需要设置）
    navStyle = .white
 2. 内容滑动到顶部时就背景色透明，按钮都显示，但是都有个半透明灰色的背景色；
    内容向下滑动之后，导航栏显示红色的背景色，按钮也都显示，但是透明色背景色的按钮；
    由 BaseVC 的 YJSNavView 实现
    navStyle = .webScroll
 3. 透明背景色的导航栏
    由 BaseVC 的 YJSNavView 实现
    navType = .normal
    navStyle = .clear
 4. 自定义的导航栏
    自己实现之后，在 YJSWebStoreVC 的 createNav() 中自己初始化
    设置 YJSWebStoreVC 的 navType = .custom
 
 另外，默认样式的导航栏还可以让 h5 设定不同的主题色
 */
@objc(YJSWebStoreVC)
@objcMembers public final class YJSWebStoreVC: YJSBaseVC {
    public weak var delegate: YJSWebStoreStateProtocol?
    public private(set) var webVC: YJSWebContentVC = YJSWebContentVC()
    public lazy var userInfo: WebJson = [:]

    // 配置URL
    public var notAddDefaultParams: Bool = false
     
    // 配置UI
    public var navStyle: YJSNavView.NavStyle = .white
    public var defaultBack: Bool = true
    
    // 配置展示方式
    public var isShowingAsView: Bool = false
    
    public var originUrl: String?                  // 原始URL
    public var storeType: YJSStoreType = .none     // 页面类型，可根据页面类型推断原始URL
    public var urlCustomParams: WebStrJson?        // 自定义参数
    public var viewTitle: String?                  // 题目
    fileprivate var navRightModels: [YJSWebNavBtnModel]?  // 导航栏右侧按钮
    fileprivate var isNavChanged: Bool = false // 导航栏是否变化了
    public var closeClosure: WebCloseClosure?      // 关闭页面时的回调
    /// 是否点击返回和手势返回都要执行 closeClosure 这个回调，默认是点击返回执行，如果设置为true，就放到didMove方法中执行
    /// 这么做是为了兼容以前的
    public var deExecute: Bool = false

    
    private var commentInputView: YJSCommentInputView?
    private var lastComentId: String = "" //上次选中的回复ID - 如果不一致，清空保存的回复内容
    /*
     此内容清空条件
     1.disAppear的时候
     2.点击发送的时候
     3.本次回复的ID和上次选中的时候不一致的时候
     
     此内容保存条件：
     1.未发送-键盘上的隐藏点击的时候
     2.未发送-点击黑色背景隐藏时候
     **/
    private var lastSaveCommentStr: String = "" //上次回复的内容-未发送需保存
    
    public override var protocolNav: YJSNavProtocol? {
        didSet {
            guard oldValue == nil, protocolNav != nil, navType == .custom else {
                return
            }
            updateWebPosition()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        super.edgeGestureEnabled = true
        view.addSubview(webVC.view)
        addChild(webVC)
        createNav()
        webVC.delegate = self
        updateWebPosition()
        loadPage()
        callModulesViewStateChanged(changed: .didLoad)
        updateNav()
    }
    
    private func updateWebPosition() {
        webVC.view.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            attachToTop(view, by: make)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callModulesViewStateChanged(changed: .willAppear)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callModulesViewStateChanged(changed: .didAppear)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callModulesViewStateChanged(changed: .willDisappear)
        cleanCommentSavedMsg()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callModulesViewStateChanged(changed: .didDisappear)
    }
    
    fileprivate func loadPage() {
        guard var url = originUrl ?? storeType.url else {
            return
        }
        urlCustomParams?.doIn({ (param) in
            if url.contains("?") {
                url.append("&\(param.key)=\(param.value)")
            } else {
                url.append("?\(param.key)=\(param.value)")
            }
        })
        if !url.contains(".zhuishushenqi.com") && !notAddDefaultParams {
            if url.contains("/mac") {
                url = url + "&idfa=\(YJIdfaHelper.idfaString() ?? "")&mac=\(YJIdfaHelper.macString() ?? "")&random=\(Date().timeIntervalSince1970)"
            }
        }
        webVC.loadWebPage(urlStr: url)
    }

    
    fileprivate func goLogin() {
        addNotificationObserver(kUserModuleWebProtocol.loginSucceedNotificationName, removeOld: true)
        kUserModuleWebProtocol.goLogin(from: self)
    }
    
    public func goBack(_ animated: Bool = true) {
        if let webItem = webVC.backButtonEventItem {
            callH5ViewWillBack(webItem)
            return
        }
        p_goBack(animated)
    }
    
    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil && deExecute == true {
            closeClosure?(userInfo)
        }
    }

    /// 增加这个方法，是因为执行pop方法的时候，不需要执行backButtonEventItem
    private func p_goBack(_ animated: Bool) {
        if deExecute == false {
            closeClosure?(userInfo)
        }
        if isShowingAsView {
            guard let superV = view.superview else {
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.view.snp.makeConstraints { (make) in
                    make.left.right.equalTo(superV)
                    make.top.equalTo(superV).offset(Screen_Height)
                    make.height.equalTo(Screen_Height)
                }
            }) { (_) in
                self.view.removeFromSuperview()
            }
        }  else if let vcs = navigationController?.viewControllers, vcs.count > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func callH5ViewWillBack(_ webItem: YJSWebItem) {
        let once = webItem.paramDic?["once"] as? Bool ?? false
        let eventParams = webItem.paramDic?["eventParams"] as? Dictionary<String, Any>
        let data = eventParams?["data"] as? String ?? ""
        let methodName = eventParams?["event"] as? String ?? ""
        webVC.runScript(methodName: methodName, params: "'\(data)'")
        if once {
            webVC.backButtonEventItem = nil
        }
    }
}

//MARK: - 监听
extension YJSWebStoreVC {
    fileprivate func addNotificationObserver(_ name: Notification.Name, removeOld: Bool) {
        if removeOld {
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: name, object: nil)
    }
        
    @objc public func handleNotification(_ notification: Notification) {
        switch notification.name {
        case kUserModuleWebProtocol.loginSucceedNotificationName:
            loadPage()
        default:
            break
        }
    }
}

//MARK: - 导航栏更新
extension YJSWebStoreVC {
    // 从左往右插入
    @objc public func appendNavModel(title: String?, imgName: String?, needsLogin: Bool, handler: (() -> ())?) {
        if let title = title {
            let content = YJSWebNavBtnModel(title: title, needsLogin: needsLogin, handler: handler)
            appendNavModel(btnModel: content)
        } else if let imgName = imgName {
            let content = YJSWebNavBtnModel(imgName: imgName, needsLogin: needsLogin, handler: handler)
            appendNavModel(btnModel: content)
        } else {
            return
        }
        isNavChanged = true
    }
    
    // 从左往右插入
    @objc public func appendWebNav(innerBtnType: YJSWebNavBtnInnerType) {
        let content = YJSWebNavBtnModel(innerType: innerBtnType)
        appendNavModel(btnModel: content)
        isNavChanged = true
    }
    
    // 重置导航栏类型
    public func setWebNav(innerBtnTypes: [YJSWebNavBtnInnerType]) {
        let models = innerBtnTypes.map {
            YJSWebNavBtnModel(innerType: $0)
        }
        navRightModels = models
        isNavChanged = true
    }
    
    fileprivate func appendNavModel(btnModel: YJSWebNavBtnModel) {
        if let _ = navRightModels {
            navRightModels?.append(btnModel)
        } else {
            navRightModels = [btnModel]
        }
    }
    
    fileprivate var navContents: [YJSNavItemContent]? {
        guard let navItems = navRightModels else {
            return nil
        }
        return navItems.flatMap { (item) -> YJSNavItemContent? in
            var content: YJSNavItemContent? = nil
            if let imgName = item.imgName {
                content = YJSNavItemContent(localImgName: imgName)
            } else if let title = item.title {
                content = YJSNavItemContent(title: title)
            }
            return content
        }
    }
    
    fileprivate func updateNav() {
        if !isNavChanged {
            return
        }
        isNavChanged = false
        navContents.doIfSome { (contents) in
            setupRightBarItems(navItems: contents)
        }
    }
}

//MARK: - 导航栏
extension YJSWebStoreVC {
    fileprivate var navBarView: YJSNavView? {
        navView as? YJSNavView
    }
    
    fileprivate func createNav() {
        // 过滤掉需要自定义导航栏的类型，这个也可以让外面传进来导航栏类型，但是那样需要传的地方有点多，所以就放在这里了
        let customNavTypes: [YJSStoreType] = [.bigGodMaster, .bigGodTopicDetail]
        if customNavTypes.contains(storeType) {
            navType = .custom
        }
        if navType == .normal {
            setupNavBar(style: navStyle, title: viewTitle, defaultBack: defaultBack)
            if navStyle == .webScrollTheme {
                setWebNav(innerBtnTypes: [.refresh])
            }
            navContents.doIfSome { (contents) in
                setupRightBarItems(navItems: contents)
            }
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func onLeftClicked(at index: Int) -> Bool {
        goBack()
        return true
    }
    
    public func changeNav(to config: WebStrJson) {
        guard let bgStr = config["background"], let colorStr = config["color"], let backStr = config["back"] else {
            return
        }
        let bgColor = Color_Hex(bgStr)
        let titleColor = Color_Hex(colorStr)
        let isRedBack = backStr == "red"
        updateStyle(titleColor: titleColor, bgColor: bgColor, isRedBack: isRedBack)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func onRightClicked(at index: Int) {
        navRightModels.doIfSome { (items) in
            guard items.count > index else {
                return
            }
            let item = items[index]
            // 需要登录
            guard !item.needsLogin || kUserModuleWebProtocol.isLogin() else {
                goLogin()
                return
            }
            if let handler = item.handler {
                handler()
            } else if let innerType = item.innerType {
                callModulesHandle(navItem: innerType)
            }
        }
    }
}

//MARK: - 评论框
extension YJSWebStoreVC {
    fileprivate func showInputTextView(webItem: YJSWebItem) {
        guard let _ = commentInputView else { //不成立走这里
            let tempInput = YJSCommentInputView()
            commentInputView = tempInput
            view.addSubview(tempInput)
        guard let parDic = webItem.paramDic else {
            return
        }
        var replayDic: WebJson = parDic
        //默认框中显示的
            let replayDefalutStr = replayDic.getStrValue("replay") ?? "@追书官方:"
        commentInputView?.updateTextViewPlaceHolder(placeHolder: replayDefalutStr)

        let replayId = replayDic.getStrValue("topicId") ?? ""
        if replayId != lastComentId {
            cleanCommentSavedMsg()
        }
        if !lastSaveCommentStr.isBlank {
            commentInputView?.updateTextView(preTextStr: lastSaveCommentStr)
        }
        //隐藏保存信息
        commentInputView?.inputViewCloseClosure = { [weak self] (inputText) in
            self?.lastSaveCommentStr = inputText
            self?.removeInputTextView()
        }
        //发送-不保存信息
        commentInputView?.sendClosure =  { [weak self] (inputText) in
            self?.removeInputTextView()
            //将回复的字符串拼接到回调函数
            replayDic["result"] = inputText
            let jsonReplayStr = replayDic.jsonString() ?? ""
            let webjsCallBack = webItem.jsCallback
            guard let callBackStr = webjsCallBack else {
                return
            }
            if !jsonReplayStr.isBlank {
                //拼接CallBck
                let temp = callBackStr + "(" + jsonReplayStr + ")"
                self?.webVC.runScript(temp)
            }
            self?.cleanCommentSavedMsg()
        }
        //上次回复的ID
        lastComentId = replayId
            return
        }
    }
    
    fileprivate func cleanCommentSavedMsg() {
        lastSaveCommentStr = ""
    }
    
    
    fileprivate func removeInputTextView() {
        inputView?.removeFromSuperview()
        commentInputView = nil
    }
}

//MARK: - WebContent 代理
extension YJSWebStoreVC : YJSWebContentDelegate {
    public func webView(_ web: YJSWebContentVC, h5CallViewClose animated: Bool) {
        goBack(animated)
    }
    
    public func webView(_ web: YJSWebContentVC, h5CallViewPop jsCallback: String?) {
        p_goBack(true)
        // 如果backEvent == nil， 并且jsCallback != nil 还是要执行js
        if web.backEventItem != nil {
            return
        }
        guard let js = jsCallback else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.preWebVC?.runScript(js)
        }
    }
    
    public func webView(_ web: YJSWebContentVC, setEventVCOptionButton webItem: YJSWebItem) {
        guard let typeStr = webItem.paramDic?["type"] as? String,
            let type = YJSWebNavBtnInnerType.from(typeStr) else {
            return
        }
        setWebNav(innerBtnTypes: [type])
        navContents.doIfSome { (contents) in
            setupRightBarItems(navItems: contents)
        }
    }
    
    //  在当前页面消失时，在前一个页面执行
    public func webView(_ web: YJSWebContentVC, h5CallViewBack callback: String?) {
        guard let js = callback else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.preWebVC?.runScript(js)
        }
    }
    
    // 上一个网页：用于返回的时候执行 backItem
    private var preWebVC: YJSWebContentVC? {
        let cur = UIApplication.getCurrentVC()
        if let webStore = cur as? YJSWebStoreVC {
            return webStore.webVC
        }
        return p_findPreWebContentVC(cur)
    }
    
    private func p_findPreWebContentVC(_ origin: UIViewController?) -> YJSWebContentVC? {
        var children: [UIViewController] = []
        
        children.append(contentsOf: origin?.children.reversed() ?? [])
        
        while let sub = children.first {
            if let web = sub as? YJSWebStoreVC {
                return web.webVC
            } else if let web = sub as? YJSWebContentVC {
                return web
            }
            children.remove(sub)
            children.append(contentsOf: sub.children.reversed())
        }
        return nil
    }
    
    public func webView(_ web: YJSWebContentVC, didChangedTitle title: String) {
        if self.viewTitle?.isEmpty ?? true {
            self.updateTitle(title)
        }
    }
    
    public func webView(_ web: YJSWebContentVC, didSetNavBarStyle style: Dictionary<String, String>) {
        changeNav(to: style)
    }
    
    public func webView(_ web: YJSWebContentVC, didScroll scrollView: UIScrollView) {
        (navView as? YJSNavProtocol)?.didScroll(to: scrollView.contentOffset.y)
    }
    
    @objc public func webView(_ web: YJSWebContentVC, didChangeNav navMsgDic: WebJson?) {
        if (storeType == YJSStoreType.bigGodMaster || storeType == YJSStoreType.bigGodTopicDetail) && (navType == .custom) {
            guard let subscribed = navMsgDic?["subscribed"] as? Bool else {
                return
            }
            
            let subscribeKey = YJSNavConfigKey(rawValue: "subscribed")
            var config: [YJSNavConfigKey : Any] = [subscribeKey : subscribed]
            
            if let userIcon = navMsgDic?["userIcon"] as? String {
                let userIconKey = YJSNavConfigKey(rawValue: "userIcon")
                config[userIconKey] = userIcon
            }
            
            if let userName = navMsgDic?["userName"] as? String {
                let userNameKey = YJSNavConfigKey(rawValue: "userName")
                config[userNameKey] = userName
            }
            protocolNav?.update(config: config)
            userInfo["subscribed"] = subscribed
        }
    }
    
    public func viewStateChanged(webVC: YJSWebContentVC, changed: ViewStateChange) {
        if changed == .webDidFinishError {
            protocolNav?.showFixedView()
        }
        if changed.isWebState {
            delegate?.viewStateChanged?(webStore: self, changed: changed)
        }
    }
}

//MARK: - 调用其他模块方法
extension YJSWebStoreVC {
    fileprivate func callModulesViewStateChanged(changed: ViewStateChange) {
        let create = changed != .didDealloc // 如果是 didDealloc，就不创建 moduleIntances，否则会闪退
        webVC.moduleIntances(create: create)?.values.doIn { (pro) in
            pro.viewStateChanged?(webStore: self, changed: changed)
        }
        delegate?.viewStateChanged?(webStore: self, changed: changed)
    }
    
    fileprivate func callModulesHandle(navItem: YJSWebNavBtnInnerType) {
        webVC.moduleIntances()?.values.doIn { (pro) in
            pro.handle?(navItem: navItem, webStore: self)
        }
    }
    
    public func triggle(navItem: YJSWebNavBtnInnerType) {
        callModulesHandle(navItem: navItem)
    }
}

//MARK: - 适配 OC
extension YJSWebStoreVC {
    @objc public func setNavRightItems(_ items: [NSNumber]) {
        let navRightItems: [YJSWebNavBtnInnerType] = items.compactMap { (num) in
            YJSWebNavBtnInnerType(rawValue: num.intValue)
        }
        self.setWebNav(innerBtnTypes: navRightItems)
    }
    
    @objc public func setToUserInfo(value: Any?, for key: String) {
        guard let _ = value else {
            userInfo.removeValue(forKey: key)
            return
        }
        userInfo[key] = value
        webVC.setToUserInfo(value: value, for: key)
    }
}
