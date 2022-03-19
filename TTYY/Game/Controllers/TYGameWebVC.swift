//
//  TYGameWebVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/13.
//

import Foundation
import UIKit
import WebKit
import SnapKit
import BaseModule

class TYGameWebVC: TYBaseVC {
    private var webView: WKWebView? // 展示的 Web
    private var url = ""
    private var errorView: YJSEmptyDataView? // 错误页
    
    convenience init(isPush: Bool) {
        self.init()
        webViewInit()
        if isPush {
            setupNavBar(title: "任务详细")
            webView?.snp.remakeConstraints({ make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(Screen_NavHeight)
            })
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

private extension TYGameWebVC {
    func webViewInit() {
        // 创建 WKUserContentController
        let wkUController = WKUserContentController()
        let handler = TYWebScriptHandler(self)
        wkUController.add(handler, name: "openSafari")
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
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
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

extension TYGameWebVC: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String, message.name == "openSafari" else { return }
        if let url = URL(string: body) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let webUrl = navigationAction.request.url else {
            return
        }
        let urlStr = webUrl.absoluteString
        if url == urlStr {
            decisionHandler(.allow)
        } else {
            let vc = TYGameWebVC(isPush: true)
            vc.loadWebPage(url: urlStr)
            parent?.navigationController?.pushViewController(vc, animated: true)
            decisionHandler(.cancel)
        }
    }
}

extension TYGameWebVC: WKUIDelegate {

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


// 因为 WKWebView 的 scripthandler 有不释放问题，所以使用 TYWebScriptHandler 做中转
private class TYWebScriptHandler: NSObject, WKScriptMessageHandler {
    weak var handler: TYGameWebVC?
    
    init(_ handler: TYGameWebVC) {
        self.handler = handler
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
