//
//  TYShopNativeVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/9.
//

import UIKit
import BaseModule
import YJSWebModule

class TYShopNativeVC: TYBaseVC {
    
    /// 搜索view
    private var searchView = TYShopSearchView()
    /// 分类
    private var categoryView = TYShopCategoryView()
    /// 全部分类
    private var allCategoryView = TYShopAllCategoryView()
    /// 分类数据
    private var categorys: [TYBaseConfigModel]?
    
    /// scrollView用来包住两个控制器
    private var scrollView = UIScrollView()
    /// 推荐控制器
    private var recommendVC: TYShopRecommendVC?
    /// 分类控制器
    private var categoryVC: TYShopCategoryVC?
    
    private var sharedIds = TYCacheHelper.getSharedGoodsIds()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        createAllCategoryView()
        requestCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !TYUserInfoHelper.userIsLogedIn() {
//            let vc = TYLoginVC()
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    /// 如果不是合伙人，直接返回false，是合伙人，包含返回false，不包含返回true
    func getBottomBtnState(productId: String) -> Bool {
        let type = TYUserInfoHelper.getUserType()
        if type == 2 {
            // 合伙人
            if sharedIds.contains(productId) {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    /// 保存已经复制过文字，分享过图片的商品
    func saveSharedId(_ productId: String) {
        sharedIds.append(productId)
        TYCacheHelper.saveSharedGoodsIds(sharedIds)
    }
}

private extension TYShopNativeVC {
    func createSubviews() {
        view.backgroundColor = Color_Hex(0xF8F8F8)
        // 搜索框
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavItemY)
            make.height.equalTo(Screen_IPadMultiply(58))
        }
        searchView.searchViewActionClosure = { [weak self] isSearch, keyWord in
            self?.handleSearchViewAction(isSearch, keyWord: keyWord)
        }
        // 分类
        view.addSubview(categoryView)
        categoryView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.height.equalTo(Screen_IPadMultiply(44))
        }
        categoryView.categoryMoreClosure = { [weak self] isRecommend, model in
            self?.categoryMoreClick(isRecommend, model)
        }
        categoryView.categoryClickClosure = { [weak self] isRecommend, model in
            self?.categoryViewClick(isRecommend, model)
        }
        // scrollView
        createScrollView()
        createRecommendVC()
    }
    
    func createScrollView() {
        view.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: Screen_Width * 2, height: 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(categoryView.snp.bottom)
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
    }
    
    func createRecommendVC() {
        if recommendVC == nil {
            recommendVC = TYShopRecommendVC()
            addChild(recommendVC!)
            scrollView.addSubview(recommendVC!.view)
        }
        recommendVC?.view.snp.remakeConstraints { make in
            make.width.top.left.equalToSuperview()
            make.height.equalToSuperview()
        }
        recommendVC?.jumpJDCategoryClosure = { [weak self] in
            self?.jumpJDCategory()
        }
    }
    
    func createCategoryVC() {
        if categoryVC == nil {
            categoryVC = TYShopCategoryVC()
            addChild(categoryVC!)
            scrollView.addSubview(categoryVC!.view)
        }
        categoryVC?.view.snp.remakeConstraints { make in
            make.width.top.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(Screen_Width)
        }
    }
    
    /// 创建所有分类的view，放在最后创建
    func createAllCategoryView() {
        view.addSubview(allCategoryView)
        allCategoryView.isHidden = true
        allCategoryView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(categoryView.snp.bottom)
        }
        allCategoryView.categoryClickClosure = { [weak self] info in
            self?.allCategorySelectedCategory(info)
        }
    }
}

private extension TYShopNativeVC {
    /// 分类更多点击
    func categoryMoreClick(_ isRecommend: Bool, _ model: TYBaseConfigModel?) {
        if isRecommend == false && model == nil  {
            return
        }
        if allCategoryView.isHidden {
            if isRecommend {
                let recommendModel = TYBaseConfigModel(name: "recommend", value: "推荐", key: "1000", sort: 1000)
                allCategoryView.show(selectedInfo: recommendModel)
            } else {
                if let info = model {
                    allCategoryView.show(selectedInfo: info)
                }
            }
        } else {
            allCategoryView.hide()
        }
    }
    /// 分类点击
    func categoryViewClick(_ isRecommend: Bool, _ model: TYBaseConfigModel?) {
        if isRecommend == false && model == nil  {
            return
        }
        allCategoryView.hide()
        refreshCategoryVC(isRecommend, model)
    }
    
    /// 所有分类中点击
    func allCategorySelectedCategory(_ info: TYBaseConfigModel) {
        categoryView.configCategory(info)
        refreshCategoryVC(info.sort == 1000, info)
    }
    
    func refreshCategoryVC(_ isRecommend: Bool, _ info: TYBaseConfigModel?) {
        if isRecommend {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            createRecommendVC()
        } else {
            guard let model = info else { return }
            scrollView.setContentOffset(CGPoint(x: Screen_Width, y: 0), animated: true)
            createCategoryVC()
            categoryVC?.updateCategory(model)
        }
    }
    
    /// 跳转到京东秒杀分类
    func jumpJDCategory() {
        guard let infos = categorys else { return }
        var jdInfo: TYBaseConfigModel? = nil
        for info in infos {
            if info.value == "京东秒杀" {
                jdInfo = info
                break
            }
        }
        guard let jd = jdInfo else { return }
        categoryView.configCategory(jd)
        scrollView.setContentOffset(CGPoint(x: Screen_Width, y: 0), animated: true)
        createCategoryVC()
        categoryVC?.updateCategory(jd)
    }
    
    func handleSearchViewAction(_ isSearch: Bool, keyWord: String) {
        if isSearch == false {
            let vc = TYContactUsVC()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            view.endEditing(true)
            if keyWord.isBlank {
                return
            }
            var url = TYOnlineUrlHelper.getSearchProductURL() + "?search_source=优选"
            url = url + "&val=" + keyWord
            let keys = TYCacheHelper.getHistoryKeyWordArray(for: kSaveSearchKeyWordHistoryKey)
            let count = keys?.count ?? 0
            if count == 0 {
                url = url + "&clearSearchHistory=true"
            }
            goWebView(url: url)
        }
    }
    
    func goWebView(url: String) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        navigationController?.pushViewController(web, animated: true)
    }
}

private extension TYShopNativeVC {
    
    /// 请求分类
    func requestCategory() {
        TYHomeService.requestBaseConfig(type: "items") { [weak self] isSuccess, categorys in
            self?.categorys = categorys
            self?.categoryView.updateCategorys(categorys)
            self?.allCategoryView.updateAllCategory(categorys)
        }
    }
}
