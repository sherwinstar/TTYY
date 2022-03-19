//
//  YJSWebContentVC.swift
//  YouShaQi
//
//  Created by Admin on 2020/7/31.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SnapKit
import BaseModule

//MARK: - 定义代理方法
@objc public protocol YJSWebContentDelegate: YJSWebContentStateProtocol {
    @objc optional func webView(_ web: YJSWebContentVC, h5CallViewClose animated: Bool)
    @objc optional func webView(_ web: YJSWebContentVC, h5CallViewPop jsCallback: String?)
    @objc optional func webView(_ web: YJSWebContentVC, h5CallViewBack jsCallback: String?)
    @objc optional func webView(_ web: YJSWebContentVC, didChangedTitle title: String)
    @objc optional func webView(_ web: YJSWebContentVC, didSetNavBarStyle style: Dictionary<String, String>)
    @objc optional func webView(_ web: YJSWebContentVC, didScroll scrollView: UIScrollView)
    @objc optional func webView(_ web: YJSWebContentVC, setEventVCOptionButton webItem: YJSWebItem)
    @objc optional func webView(_ web: YJSWebContentVC, didChangeNav navMsgDic: WebJson?)
    @objc optional func webViewGodCommentClick(_ web: YJSWebContentVC, webItem: YJSWebItem)
}

@objc(YJSWebContentVC)
@objcMembers public final class YJSWebContentVC: YJSBaseVC {
    public weak var delegate: YJSWebContentDelegate?
    /// 当前链接是否需要转义
    public var needEncode: Bool = true
    public var needPlatform: Bool = true
    /// webView顶部距离
    public var topMargin: CGFloat = 0
    /// 转义后拼接的数据
    public var appendAfterEncodeStr = ""

    
    // 其他模块实例，用于完成各自模块的事情
    private(set) var moduleIntances: [String : YJSWebToModuleProtocol]?
    
    /*
     之所以这么麻烦的自己实现 lazy，是为了要避免出现这种问题：
     webVC 被创建后直接没有用就销毁了
     所以给 moduleIntances 发的第一个消息就是 dealloc，一收到消息就要实例化 moduleIntances，实例化 moduleIntances 需要把 self 传进去，但此时的 self 是 dealloc 的，所以就是闪退了
     所以在收到 dealloc 消息时不实例化 moduleIntances，由 create 参数控制是否要实例化 moduleIntances
     */
    func moduleIntances(create: Bool = true) -> [String : YJSWebToModuleProtocol]? {
        if moduleIntances == nil && create {
            moduleIntances = kModuleWebProtocols.reduce(into: [:]) { (result, pro) in
                result[pro.moduleIdentifier] = pro.init(webVC: self)
            }
        }
        return moduleIntances
    }
    
    // 提供给其他模块保存它们需要的属性的
    public lazy var userInfo: WebJson = [:]
    
    //TODO:汤娟娟 暂时我也不知道
    var navRightItems: [YJSWebItem]?

    fileprivate var loadedUrlStr: String? // 被处理后的URL
    public private(set) var webView: WKWebView? // 展示的 Web
    // 当前 h5 是否正在展示，初衷是为了避免 h5 消失的同时有弹窗，而导致的系统回调不调用，而导致的闪退
    fileprivate var isShowing: Bool = false
    
    fileprivate var errorView: YJSEmptyDataView? // 错误页
    
    /*----- 需要在特定时机回调的 WebItem ----*/
    // 如果 h5 设置了导航栏右侧按钮，那么当按钮被点击时，需要回调的 WebItem
    public var rightBtnItem: YJSWebItem?
    // 当网页关闭时，需要回调的 WebItem
    public var backEventItem: YJSWebItem?
    // 当点击返回按钮时，需要回调的 WebItem，注意：跟 backEventItem 调用的时机不一样（目前只有 福利社 用到了）
    public var backButtonEventItem: YJSWebItem?
    
    
    //评论add-start
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
    //end
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        webView?.removeObserver(self, forKeyPath: "title")
        callModuleViewStateChanged(.didDealloc)
        // removeAllUserScripts() 还是会导致不释放，得用 removeScriptMessageHandler
        #if TARGET_TTYY
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "ttyyApi")
        #else
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "ZssqApi")
        #endif
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        webViewInitialize()
        addObserver()
        callModuleViewStateChanged(.didLoad)
    }
    
    @objc public func loadWebPage(urlStr: String?) {
        guard let urlStr = urlStr else {
            return
        }
        var curUrlStr = urlStr
        if let host = URL.encodeFrom(curUrlStr)?.host, host.contains(".zhuishushenqi.com") {
            curUrlStr = modifyUrlStr(urlStr)
        }
        loadedUrlStr = curUrlStr
        if needEncode {
            guard let url = URL.encodeFrom(curUrlStr) else {
                return
            }
            let request = URLRequest(url: url)
            webView?.load(request)
        } else {
            if var encodedStr = curUrlStr.removingPercentEncoding?.yjs_allEncodedURLString() {
                #if TARGET_TTYY
                if !appendAfterEncodeStr.isBlank {
                    encodedStr = encodedStr + appendAfterEncodeStr
                }
                #endif
                guard let url = URL(string: encodedStr) else {
                    return
                }
                let request = URLRequest(url: url)
                webView?.load(request)
            }
        }
    }

    @objc public func runScript(methodName: String, params: String?) {
        let script: String
        if let params = params {
            script = "HybridApi._Event.emitTemp({'event':'\(methodName)','data':\(params)})"
        } else {
            script = "HybridApi._Event.emitTemp({'event':'\(methodName)'})"
        }
        runScript(script)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callModuleViewStateChanged(.didAppear)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callModuleViewStateChanged(.willAppear)
        isShowing = true
        //TODO:汤娟娟 因为不知道页面浏览事件H5用的是WebEvent还是用WebStor进行的跳转，但是最终两个都走这里，你看看放哪里合适。就是页面浏览事件的开始上传--现在是放在了webToLog中的stateChange代理处理
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShowing = false
        backEventItem?.jsStr().doIfSome {
            delegate?.webView?(self, h5CallViewBack: $0)
        }
        callModuleViewStateChanged(.willDisappear)
        
        //评论add-start
        cleanCommentSavedMsg()
        //end
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callModuleViewStateChanged(.didDisappear)
    }
    
    @objc public func runScript(_ script: String) {
        doInMain {
            self.webView?.evaluateJavaScript(script) { (call, error) in
                if let error = error {
                    debugPrint("\(error.localizedDescription)\n\(script)")
                }
            }
        }
    }
    
    @objc public func reloadWeb() {
        #if DEBUG
        //TODO:汤娟娟 2020-10-20：这种处理方式理论上没有问题，但是我们还是有点忐忑，所以现在debug模式下运行一段时间，如果没有发现问题，就用这种方式
        guard let url = webView?.url?.absoluteString else {
            return
        }
        loadWebPage(urlStr: url)
        #else
        let curUrl: String?
        if loadedUrlStr?.contains("/public/dashen/explore.html") ?? false {
            curUrl = webView?.url?.absoluteString
        }  else {
            curUrl = loadedUrlStr
        }
        guard let url = curUrl else {
            return
        }
        loadWebPage(urlStr: url)
        #endif
    }
    
    @objc public func goBack() {
        webView?.goBack()
    }
    
    @objc public func goForward() {
        webView?.goForward()
    }
    
    @objc public func reload() {
        webView?.reload()
    }
    
    @objc public func canGoBack() -> Bool {
        webView?.canGoBack ?? false
    }
    
    @objc public func canGoForward() -> Bool {
        webView?.canGoForward ?? false
    }
}

//MARK: - 初始化
extension YJSWebContentVC {
    private func webViewInitialize() {
        // 创建 WKUserContentController
        let wkUController = WKUserContentController()
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController;
        // 创建脚本
        let jScript = """
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');\
        meta.setAttribute('content', 'width=device-width');\
        document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        wkUController.addUserScript(wkUScript)
        
        // 添加 ZssqApi
        let handler = YJSWebScriptHandler(self)
        #if TARGET_TTYY
        wkUController.add(handler, name: "ttyyApi")
        #else
        wkUController.add(handler, name: "ZssqApi")
        #endif
        
        // 创建 webview
        let webView = WKWebView(frame: view.frame, configuration: wkWebConfig)
        self.webView = webView
        webView.isOpaque = false
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            edgesForExtendedLayout = []
        }
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsLinkPreview = false
        webView.scrollView.delegate = self
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            #if TARGET_TTYY
            make.top.equalToSuperview().offset(topMargin)
            make.left.right.bottom.equalToSuperview()
            #else
            make.edges.equalTo(self.view)
            #endif
        }
        
        callModuleViewStateChanged(.webViewIntial)
    }
}

//MARK: - 处理URL
extension YJSWebContentVC {
    private func modifyUrlStr(_ origin: String) -> String {
        var urlStr = origin
        #if TARGET_TTYY
        // 平台
        if needPlatform {
            append(to: &urlStr, ifNotContains: "platform=ios") { () -> (String) in
                "platform=ios"
            }
        }
        return urlStr
        #endif
        var isAddedTimeStamp = false
        // 时间戳
        if !urlStr.contains("vipCenterForIos2.html") {
            append(to: &urlStr, ifNotContains: "timestamp=") { () -> (String) in
                isAddedTimeStamp = true
                return "timestamp=\(Date().timeIntervalSince1970)"
            }
        }
        // 性别
        append(to: &urlStr, ifNotContains: "gender=") { () -> (String) in
            let gender = kUserModuleWebProtocol.userGender() ?? "male"
            return "gender=\(gender)"
        }
        // 版本
        append(to: &urlStr, ifNotContains: "[&?]version=") { () -> (String) in
            "version=\(UIApplication.yjs_h5Version())"
        }
        // token
        if kUserModuleWebProtocol.isLogin() && !(kUserModuleWebProtocol.userToken()?.isEmpty ?? true) {
            append(to: &urlStr, ifNotContains: "token=") { () -> (String) in
                "token=\(kUserModuleWebProtocol.userToken() ?? "")"
            }
        }
        // 用户ID
        append(to: &urlStr, ifNotContains: "userid=") { () -> (String) in
            "userid=\(kUserModuleWebProtocol.userUniqueId() ?? "")"
        }
        // 平台
        append(to: &urlStr, ifNotContains: "platform=ios") { () -> (String) in
            "platform=ios"
        }
        // 包名
        append(to: &urlStr, ifNotContains: "packageName=") { () -> (String) in
            "packageName=\(UIApplication.yjs_bookApiPackageName())"
        }
        // 青少年模式
        append(to: &urlStr, ifNotContains: "youthModel=") { () -> (String) in
            let youngMode = kUserModuleWebProtocol.youngMode() ? "true" : "false"
            return "youthModel=\(youngMode)"
        }

        if !isAddedTimeStamp {
            updateTimeStamp(&urlStr)
        }
        return urlStr
    }
    
    private func updateTimeStamp(_ urlStr: inout String) {
        let r = urlStr.range(of: "timestamp=[\\d\\.]+", options: .regularExpression)
        if let range = r {
            urlStr = urlStr.replacingCharacters(in: range, with: "timestamp=\(Date().timeIntervalSince1970)")
        }
    }
    
    private func append(to origin: inout String, ifNotContains token: String, param: () -> (String)) {
        if !origin.contains(token) {
            if !origin.contains("?") {
                origin.append("?")
            } else {
                origin.append("&")
            }
            origin.append(param())
        }
    }
}

//MARK: - 事件处理
extension YJSWebContentVC: WKNavigationDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        #if TARGET_TTYY
        guard let body = message.body as? WebJson, message.name == "ttyyApi", let action = body.getStrValue("action") else {
            return
        }
        #else
        guard let body = message.body as? WebJson, message.name == "ZssqApi", let action = body.getStrValue("action") else {
            return
        }
        #endif
        let webItem = YJSWebItem(funcName: action, query: nil, param: body)
        handleWebItem(webItem)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return
        }
        let urlStr = url.absoluteString
        if parseUrl(urlStr) { // jsbridge 有最高优先级
            decisionHandler(.cancel)
        } else if urlStr.contains("apple.com") { // 广告
            UIApplication.customOpenUrlStr(urlStr)
            decisionHandler(.allow)
            delegate?.webView?(self, h5CallViewClose: true)
        } else if urlStr.isiTunesURL() || urlStr.isAppStoreURL() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            delegate?.webView?(self, h5CallViewClose: true)
        } else if urlStr.hasPrefix("http") {
            decisionHandler(.allow)
            callModuleViewStateChanged(.webBeginLoad)
        } else {
            decisionHandler(.cancel)
            UIApplication.customOpenUrlStr(urlStr)
        }
    }
    
    /// 解析/处理URL
    /// - Parameter urlStr: URL
    /// - Returns:true: 可以处理, false: 不可以处理
    private func parseUrl(_ urlStr: String) -> Bool {
        let url = urlStr.replacingOccurrences(of: "/?", with: "?")
        if let webItem = url.parserToWebItem() {
            return handleWebItem(webItem)
        }
        return false
    }
    
    @discardableResult
    func handleWebItem(_ webItem: YJSWebItem) -> Bool {
        if webItem.funcName == "jump", let jump = webItem.jump, jump.needsLogin() && !kUserModuleWebProtocol.isLogin() {
            if let parent = self.parent {
                kUserModuleWebProtocol.goLogin(from: parent)
            }
            return true
        }
        let handler: YJSWebToModuleProtocol? = moduleIntances()?.values.first { (pro) -> Bool in
            let result = pro.canHandleWebItem(webItem: webItem)
            return result
        }
        handler?.handle?(webItem: webItem, context: YJSWebContext(fromVC: self, delegate: delegate), callback: { [weak self] js in
            self?.runScript(js)
        })
        return true
    }
}

//评论add-start
extension YJSWebContentVC {
    //这个是代理，需要弹出评论框的
    func webViewGodCommentClick(_ web: YJSWebContentVC, webItem: YJSWebItem) {
        //添加评论框
        showInputTextView(webItem: webItem)
    }
    
    public func showInputTextViewTest(webItem: YJSWebItem) {
        showInputTextView(webItem: webItem)
    }
    
    fileprivate func showInputTextView(webItem: YJSWebItem) {
        guard let webInputView = commentInputView else { //不成立走这里
            let tempInput = YJSCommentInputView()
            commentInputView = tempInput
            return
        }
        guard let parDic = webItem.paramDic else {
            return
        }
        
        UIApplication.shared.keyWindow?.addSubview(webInputView)
        var replayDic: WebJson = parDic
        //默认框中显示的
        let replaceDicStr = replayDic.getStrValue("replay") ?? ""
                    let replayDefalutStr = replaceDicStr.isBlank ? YJLanguageHelper.translateStr("随书而起，有感而发") : YJLanguageHelper.translateStr("@" + replaceDicStr)
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
            if inputText.isBlank {
            
               YJSToast.show(YJLanguageHelper.translateStr("发布评论不能为空"))
                self?.removeInputTextView()
               return
           }
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
                self?.runScript(temp)
            }
            self?.cleanCommentSavedMsg()
        }
        //上次回复的ID
        lastComentId = replayId
    }
    
    fileprivate func cleanCommentSavedMsg() {
        lastSaveCommentStr = ""
    }
    
    
    fileprivate func removeInputTextView() {
        commentInputView?.removeFromSuperview()
        commentInputView = nil
    }
}
//end

//MARK: - 调用其他模块的方法
extension YJSWebContentVC {
    fileprivate func callModuleViewStateChanged(_ changed: ViewStateChange) {
        let create = changed != .didDealloc // 如果是 didDealloc，就不创建 moduleIntances，否则会闪退
        moduleIntances(create: create)?.values.doIn {
            $0.viewStateChanged?(webVC: self, changed: changed)
        }
        delegate?.viewStateChanged?(webVC: self, changed: changed)
    }
}

//MARK: - scrollview 代理
extension YJSWebContentVC : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webView?(self, didScroll: scrollView)
    }
}

//MARK: - 运行状态回调
extension YJSWebContentVC: WKUIDelegate {
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        reload()
    }
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent?.view.hideProgress()
        hideErrorView()
        callModuleViewStateChanged(.webDidFinishLoad)
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        parent?.view.hideProgress()
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        parent?.view.hideProgress()
        if let _ = webView.backForwardList.currentItem {
            return
        }
        let nsError = error as NSError
        
        if let failed = nsError.userInfo.getStrValue(NSURLErrorFailingURLStringErrorKey),
           !failed.isiTunesURL(),
           !failed.isAppStoreURL() {
            showErrorView()
        }
        callModuleViewStateChanged(.webDidFinishError)
    }
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        parent?.view.showProgress()
    }
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard isShowing else {
            completionHandler()
            return
        }
        let alert = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "关闭".yjs_translateStr(), style: .cancel, handler: { _ in    completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard isShowing else {
            completionHandler(false)
            return
        }
        let alert = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的".yjs_translateStr(), style: .cancel, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消".yjs_translateStr(), style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if prompt == "getDeviceInfo" {
            let handler: YJSWebToModuleProtocol? = moduleIntances()?.values.first { (pro) -> Bool in
                let result = pro.canHandleAction?(action: "sync_getDeviceInfo")
                return result ?? false
            }
            if let syncString =  handler?.getSyncInfo?(action: "sync_getDeviceInfo"), !syncString.isBlank {
                completionHandler(syncString)
            } else {
                completionHandler(nil)
            }
            return
        } else if prompt == "isShowRedPackageInviteDialog" {
            let handler: YJSWebToModuleProtocol? = moduleIntances()?.values.first { (pro) -> Bool in
                let result = pro.canHandleAction?(action: "sync_isShowRedPackageInviteDialog")
                return result ?? false
            }
            
            if let syncString =  handler?.getSyncInfo?(action: "sync_isShowRedPackageInviteDialog"), !syncString.isBlank {
                completionHandler(syncString)
            } else {
                completionHandler(nil)
            }
            return
        }
        guard isShowing else {
            completionHandler(nil)
            return
        }
        let alert = UIAlertController(title: webView.url?.host, message: prompt, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "好的".yjs_translateStr(), style: .default, handler: { _ in
            completionHandler(alert.textFields?.first?.text)
        }))
        alert.addAction(UIAlertAction(title: "取消".yjs_translateStr(), style: .cancel, handler: { _ in
            completionHandler(nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    fileprivate func showErrorView() {
        super.showToast(msg: "请连接网络后点击刷新~".yjs_translateStr())
        guard errorView == nil, let webView = self.webView else {
            return
        }
        let error = YJSEmptyDataView(frame: webView.frame, type: .network, tipMsg: nil, btnTitle: "重新加载") { [weak self] in
            self?.loadedUrlStr.doIfSome { self?.loadWebPage(urlStr: $0) }
        }
        view.addSubview(error)
        view.bringSubviewToFront(error)
        errorView = error
    }
    fileprivate func hideErrorView() {
        errorView?.removeFromSuperview()
        errorView = nil
    }
}

//MARK: - 监听
extension YJSWebContentVC {
    fileprivate func addObserver() {
        webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "title" else {
            return
        }
        let called = object as? WKWebView
        if called == webView {
            delegate?.webView?(self, didChangedTitle: webView?.title ?? "")
        }
    }
}

//MARK: - 适配 OC
extension YJSWebContentVC {
    @objc public func setToUserInfo(value: Any?, for key: String) {
        guard let _ = value else {
            userInfo.removeValue(forKey: key)
            return
        }
        userInfo[key] = value
    }
}

// 因为 WKWebView 的 scripthandler 有不释放问题，所以使用 YJSWebScriptHandler 做中转
private class YJSWebScriptHandler: NSObject, WKScriptMessageHandler {
    weak var handler: YJSWebContentVC?
    
    init(_ handler: YJSWebContentVC) {
        self.handler = handler
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
