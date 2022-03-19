//
//  TYHomeNativeVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/31.
//

import UIKit
import BaseModule
import YJSWebModule

class TYHomeNativeVC: TYBaseVC {
    private var scrollView = UIScrollView()
    private var moneyView = TYHomeMoneyView()
    /// 客服
    private var serviceBtn = UIButton()
    /// 多少人节约了多少钱
    private var numLb = UILabel()
    /// 搜索
    private var searchView = TYHomeSearchView()
    private var historyView = TYHomeSearchHistoryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        requestBaseConfig()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestRebateInfo()
    }
}

private extension TYHomeNativeVC {
    func createSubviews() {
        view.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
        scrollView.showsVerticalScrollIndicator = false
        let contentView = UIView()
        contentView.backgroundColor = .white
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(Screen_Width)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewClick))
        scrollView.addGestureRecognizer(tap)
        
        contentView.addSubview(moneyView)
        moneyView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(5))
            make.left.equalTo(Screen_IPadMultiply(30))
            make.height.equalTo(Screen_IPadMultiply(70))
            make.right.equalToSuperview()
        }
        
        moneyView.goLoginOrWithdrawClosure = { [weak self] in
            self?.goLoginOrWithdrawAction()
        }
        
        // 客服
        contentView.addSubview(serviceBtn)
        serviceBtn.setImage(UIImage(named: "mine_answer_icon"), for: .normal)
        serviceBtn.addTarget(self, action: #selector(serviceBtnClick), for: .touchUpInside)
        serviceBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-24))
            make.width.height.equalTo(Screen_IPadMultiply(34))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(10))
        }
        
        // logo
        let logoImgV = UIImageView(image: UIImage(named: "home_app_logo"))
        contentView.addSubview(logoImgV)
        logoImgV.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(150))
            make.height.equalTo(Screen_IPadMultiply(37))
            make.top.equalTo(moneyView.snp.bottom).offset(Screen_IPadMultiply(112))
            make.centerX.equalToSuperview()
        }
        
        // 人数
        contentView.addSubview(numLb)
        numLb.font = Font_System_IPadMul(12)
        numLb.textAlignment = .center
        numLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImgV.snp.bottom).offset(Screen_IPadMultiply(7))
        }
        
        // 搜索框
        contentView.addSubview(searchView)
//        searchView.backgroundColor = .red
        searchView.snp.makeConstraints { make in
            make.top.equalTo(numLb.snp.bottom).offset(Screen_IPadMultiply(15))
            make.height.equalTo(Screen_IPadMultiply(60))
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        searchView.textFieldBeginEditClosure = { [weak self] in
            self?.searchFieldClick()
        }
        searchView.textFieldEndEditClosure = { [weak self] in
            self?.searchFieldReset()
        }
        
        searchView.searchClosure = { [weak self] keyword in
            self?.goSearchResult(keyword: keyword)
        }
        let flowView = TYHomeFlowView()
        contentView.addSubview(flowView)
        let flowH = flowView.getFlowViewHeight()
        flowView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-Screen_IPadMultiply(30))
            make.height.equalTo(flowH)
            make.top.equalTo(numLb.snp.bottom).offset(Screen_IPadMultiply(87))
        }
        flowView.clickClosure = { [weak self] in
            self?.goWholeRuleView()
        }
        
        let platformView = TYHomePlatformView()
        contentView.addSubview(platformView)
        platformView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(flowView.snp.bottom).offset(Screen_IPadMultiply(26))
            make.height.equalTo(Screen_IPadMultiply(250))
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(platformView.snp.bottom).offset(Screen_IPadMultiply(25))
        }
        
        // 搜索历史
        view.addSubview(historyView)
        historyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.height.equalTo(scrollView.snp.height).offset(Screen_IPadMultiply(-60))
        }
        historyView.isHidden = true
        historyView.searchClosure = { [weak self] key in
            self?.goSearchResult(keyword: key)
        }
    }
    
    func refreshNumLb(_ models: [TYBaseConfigModel]) {
        var userCount = ""
        var moneyCount = ""
        for info in models {
            if info.key == "userCount" {
                userCount = info.value
            } else if info.key == "moneyCount" {
                moneyCount = info.value
            }
        }
        if userCount.isBlank || moneyCount.isBlank {
            return
        }
        let str = userCount + "人正在有余省钱，累计节约" + moneyCount + "元"
        let att = NSMutableAttributedString(string: str)
        att.addAttributes([.font: Font_System_IPadMul(12), .foregroundColor: Color_Hex(0x595959)], range: NSRange(location: 0, length: str.count))
        att.addAttributes([.font: Font_System_IPadMul(12), .foregroundColor: Color_Hex(0xE11521)], range: NSRange(location: str.count - moneyCount.count - 1, length: moneyCount.count))
        numLb.attributedText = att
    }
    
    @objc func scrollViewClick() {
        view.endEditing(true)
    }
    
    func searchFieldClick() {
        searchView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(60))
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.scrollView.contentOffset = .zero
            self.historyView.isHidden = false
            self.historyView.refreshData()
        }
    }
    
    func searchFieldReset() {
        searchView.snp.remakeConstraints { make in
            make.top.equalTo(numLb.snp.bottom).offset(Screen_IPadMultiply(15))
            make.height.equalTo(Screen_IPadMultiply(60))
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.historyView.isHidden = true
        }
    }
}

private extension TYHomeNativeVC {
    /// 客服
    @objc func serviceBtnClick() {
        let vc = TYContactUsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 查看完整教程
    func goWholeRuleView() {
        goWebView(url: TYOnlineUrlHelper.getCourseURL(), appendAfterEncodeStr: nil)
    }
    
    /// 登录或者提现
    func goLoginOrWithdrawAction() {
        if TYUserInfoHelper.userIsLogedIn() {
            let vc = TYWithdrawVC()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = TYLoginVC()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goSearchResult(keyword: String?) {
        view.endEditing(true)
        guard let key = keyword, !key.isBlank else { return }
        var url = TYOnlineUrlHelper.getSearchProductURL() + "?search_source=首页"
        let keys = TYCacheHelper.getHistoryKeyWordArray(for: kSaveSearchKeyWordHistoryKey)
        let count = keys?.count ?? 0
        if count == 0 {
            url = url + "&clearSearchHistory=true"
        }
        let set = NSMutableCharacterSet()
        set.formUnion(with: .alphanumerics)
        set.formUnion(with: CharacterSet(charactersIn: "-_.!~*'()"))
        let ret = key.addingPercentEncoding(withAllowedCharacters: set as CharacterSet)
        var appendAfterEncodeStr: String? = nil
        if let third = ret, !third.isBlank {
            appendAfterEncodeStr = "&val=" + third
        }
        goWebView(url: url, appendAfterEncodeStr: appendAfterEncodeStr)
    }

    func goWebView(url: String, appendAfterEncodeStr: String?) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        if let encodeStr = appendAfterEncodeStr, !encodeStr.isBlank {
            web.webVC.appendAfterEncodeStr = encodeStr
        }
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        navigationController?.pushViewController(web, animated: true)
    }
}

private extension TYHomeNativeVC {
    func requestRebateInfo() {
        TYMineService.getUserRebateInfo { [weak self] isSuccess, infoModel in
            if let info = infoModel, isSuccess {
                self?.moneyView.updateMoneyView(info.remainMoney)
            } else {
                self?.moneyView.updateMoneyView(0)
            }
        }
    }
    
    func requestBaseConfig() {
        TYHomeService.requestBaseConfig(type: "FrontTitleConfig_v2") { [weak self] isSuccess, models in
            if let infos = models, infos.count > 0, isSuccess {
                self?.refreshNumLb(infos)
            }
        }
    }
}

extension TYHomeNativeVC: TYLoginVCProtocol {
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool) {
        if state {
            requestRebateInfo()
        }
    }
}
