//
//  TYShopWebVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/17.
//

import UIKit
import WebKit
import SnapKit
import BaseModule

class TYShopWebVC: TYBaseVC {

    private var webView: WKWebView? // 展示的 Web
    private var url = ""
    private var errorView: YJSEmptyDataView? // 错误页
    
    convenience init(url: String) {
        self.init()
        webViewInit()
        self.url = url
        setupNavBar(title: "详情")
        if let playURL = URL(string: url) {
            let request = URLRequest(url: playURL)
            webView?.load(request)
        }
    }
    
    
    func loadWebPage(url: String) {
        self.url = url
        if let playURL = URL(string: url) {
            let request = URLRequest(url: playURL)
            webView?.load(request)
        }
    }
}

private extension TYShopWebVC {
    func webViewInit() {
        // 创建 WKUserContentController
        let wkUController = WKUserContentController()
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController;
        
        // 创建 webview
        let webView = WKWebView(frame: view.frame, configuration: wkWebConfig)
        self.webView = webView
        webView.isOpaque = false
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            edgesForExtendedLayout = []
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        view.addSubview(webView)
        webView.snp.remakeConstraints({ make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavHeight)
        })
    }
    
    func showErrorView() {
        guard errorView == nil, let webView = self.webView else {
            return
        }
        let error = YJSEmptyDataView(frame: webView.frame, type: .network, tipMsg: nil, btnTitle: "刷新") { [weak self] in
            if let urlStr = self?.url {
                self?.loadWebPage(url: urlStr)
            }
        }
        view.addSubview(error)
        view.bringSubviewToFront(error)
        errorView = error
    }
    func hideErrorView() {
        errorView?.removeFromSuperview()
        errorView = nil
    }
}

extension TYShopWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        guard let webUrl = navigationAction.request.url else {
//            return
//        }
//        let urlStr = webUrl.absoluteString
//        if urlStr.isiTunesURL() || urlStr.isAppStoreURL() {
//            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
//            decisionHandler(.cancel)
//            return
//        }
        decisionHandler(.allow)
    }
}


extension TYShopWebVC: WKUIDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideErrorView()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let _ = webView.backForwardList.currentItem {
            return
        }
        let nsError = error as NSError

        if let failed = nsError.userInfo.getStrValue(NSURLErrorFailingURLStringErrorKey),
           !failed.isiTunesURL(),
           !failed.isAppStoreURL() {
            showErrorView()
        }
    }
}
