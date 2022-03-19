//
//  TYShopRecommendVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule
import YJSWebModule
import MJRefresh

class TYShopRecommendVC: TYBaseVC {
    /// 跳转到京东分类
    var jumpJDCategoryClosure: (()->Void)?
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        return table
    }()
    private var shopModuleCell: TYShopModuleCell?
    private var typeHeadViewContent = UIView()
    private var typeHeadView: TYShopProductTypeView?
    
    /// 超级爆品数据
    private var exaProducts: [TYShopProductModel]?
    
    /// 1 京东 2 淘宝 3 拼多多
    private var type: Int = 1
    /// 1 智能推荐 2 9.9包邮 3 好券商品 ，4 高佣精选
    private var recomType: Int = 1
    
    private var jdPageIndex: Int = 1
    private var pddPageIndex: Int = 1
    private var tbPageIndex: Int = 1
    private var jdProducts = [TYShopProductModel]()
    private var pddProducts = [TYShopProductModel]()
    private var tbProducts = [TYShopProductModel]()
    private var showProducts = [TYShopProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        addObserver()
        requestExsRecommend()
        requestSystemRecommend()
    }
    
}

private extension TYShopRecommendVC {
    func createSubviews() {
        view.backgroundColor = Color_Hex(0xF8F8F8)
        
        view.addSubview(tableView)
        tableView.backgroundColor = Color_Hex(0xF8F8F8)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(TYRecommendBannerCell.self, forCellReuseIdentifier: "TYRecommendBannerCell")
        tableView.register(TYShopModuleCell.self, forCellReuseIdentifier: "TYShopModuleCell")
        tableView.register(TYShopHotProductCell.self, forCellReuseIdentifier: "TYShopHotProductCell")
        tableView.register(TYShopProductCell.self, forCellReuseIdentifier: "TYShopProductCell")
        if #available(iOS 11.0, *) {
           tableView.contentInsetAdjustmentBehavior = .never
           tableView.estimatedSectionFooterHeight = 0
           tableView.estimatedSectionHeaderHeight = 0
           tableView.estimatedRowHeight = 0
       }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutSuccess), name: NSNotification.Name(rawValue: TYNotificationLogoutSuccess), object: nil)
    }
}

private extension TYShopRecommendVC {
    /// 请求爆款商品
    func requestExsRecommend() {
        TYShopService.requestExaRecommend { [weak self] isSuccess, products in
            self?.exaProducts = products
            self?.tableView.reloadData()
        }
    }
    
    /// 请求推荐商品（请求第一页商品）
    func requestSystemRecommend() {
        if type == 1 {
            jdPageIndex = 1
        } else if type == 2 {
            tbPageIndex = 1
        } else if type == 3 {
            pddPageIndex = 1
        }
        tableView.mj_footer?.resetNoMoreData()
        showProgress()
        TYShopService.requestSystemRecommend(type: type, recomType: recomType, pageIndex: 1, searchId: "") { [weak self] isSuccess, products in
            self?.hideProgress()
            self?.handleSystemRecommend(isSuccess, products: products, isMore: false)
            if let infos = products, infos.count > 0 {
                self?.addRefreshFooter()
            }
        }
    }
    
    func addRefreshFooter() {
        if tableView.mj_footer == nil {
            tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(requestMoreSystemRecommend))
        }
    }
    
    @objc func requestMoreSystemRecommend() {
        var pageIndex = 1
        var searchId = ""
        if type == 1 {
            pageIndex = jdPageIndex + 1
            searchId = jdProducts.last?.searchId ?? ""
        } else if type == 2 {
            pageIndex = tbPageIndex + 1
            searchId = tbProducts.last?.searchId ?? ""
        } else if type == 3 {
            pageIndex = pddPageIndex + 1
            searchId = pddProducts.last?.searchId ?? ""
        }
        showProgress()
        TYShopService.requestSystemRecommend(type: type, recomType: recomType, pageIndex: pageIndex, searchId: searchId) { [weak self] isSuccess, products in
            self?.hideProgress()
            self?.tableView.mj_footer?.endRefreshing()
            self?.handleSystemRecommend(isSuccess, products: products, isMore: true)
            if isSuccess, products == nil {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    func handleSystemRecommend(_ isSuccess: Bool, products: [TYShopProductModel]?, isMore: Bool) {
        if let models = products, models.count > 0, isSuccess {
            if type == 1 {
                if !isMore {
                    jdProducts.removeAll()
                } else {
                    jdPageIndex += 1
                }
                jdProducts += models
                showProducts = jdProducts
            } else if type == 2 {
                if !isMore {
                    tbProducts.removeAll()
                } else {
                    tbPageIndex += 1
                }
                tbProducts += models
                showProducts = tbProducts
            } else if type == 3 {
                if !isMore {
                    pddProducts.removeAll()
                } else {
                    pddPageIndex += 1
                }
                pddProducts += models
                showProducts = pddProducts
            }
        }
        tableView.reloadData()
    }
}

private extension TYShopRecommendVC {
    func handleModuleCellAction(_ type: ShopModuleType) {
        switch type {
        case .free99, .ticket, .commission:
            goWebView(url: TYOnlineUrlHelper.getModuleURL(type: type.rawValue))
        case .jd:
            TYThirdConvertHelper.goThird(.jd)
        case .meituan:
            TYThirdConvertHelper.goThird(.meituan)
        case .pdd:
            TYThirdConvertHelper.goThird(.pdd)
        case .taobao:
            TYThirdConvertHelper.goThird(.taobao)
        case .elme:
            TYThirdConvertHelper.goThird(.eleme)
        default: break
        }
    
    }
    
    func changeType(_ type: Int) {
        self.type = type
        if type == 1 {
            if jdProducts.count > 0 {
                showProducts = jdProducts
                tableView.reloadData()
            } else {
                requestSystemRecommend()
            }
        } else if type == 2 {
            if tbProducts.count > 0 {
                showProducts = tbProducts
                tableView.reloadData()
            } else {
                requestSystemRecommend()
            }
        } else if type == 3 {
            if pddProducts.count > 0 {
                showProducts = pddProducts
                tableView.reloadData()
            } else {
                requestSystemRecommend()
            }
        }
        let y = typeHeadViewContent.frame.origin.y + typeHeadViewContent.frame.size.height + 1
        tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
    }
    
    func goWebView(url: String) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        parent?.navigationController?.pushViewController(web, animated: true)
    }
    
    func goLogin() {
        let vc = TYLoginVC()
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func saveSharedId(_ productId: String) {
        let parentVC = parent as? TYShopNativeVC
        parentVC?.saveSharedId(productId)
    }
}

extension TYShopRecommendVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 || section == 2 {
            return 1
        } else {
            return showProducts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYRecommendBannerCell", for: indexPath) as! TYRecommendBannerCell
            cell.bannerActionClosure = {[weak self] () in
                if !TYUserInfoHelper.userIsLogedIn() {
                    let loginVC = TYLoginVC()
                    self?.navigationController?.pushViewController(loginVC, animated: true)
                } else {
                    let urlStr = TYOnlineUrlHelper.getPartner()
                    let partnerWebVC = YJSWebStoreVC()
                    partnerWebVC.originUrl = urlStr
                    partnerWebVC.webVC.needEncode = false
                    partnerWebVC.webVC.topMargin = Screen_NavItemY
                    partnerWebVC.setupHiddenNav()
                    self?.navigationController?.pushViewController(partnerWebVC, animated: true)
                }
            }
            return cell
        } else if indexPath.section == 1 {
            if (shopModuleCell != nil) {//禁止重用
                return shopModuleCell!
            }
            shopModuleCell = tableView.dequeueReusableCell(withIdentifier: "TYShopModuleCell", for: indexPath) as? TYShopModuleCell
            shopModuleCell!.moduleActionClosure = { [weak self] type in
                self?.handleModuleCellAction(type)
            }
            return shopModuleCell!
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYShopHotProductCell", for: indexPath) as! TYShopHotProductCell
            cell.updateCell(productModels: exaProducts)
            cell.goProductDetailClosure = { [weak self] product in
                if TYUserInfoHelper.userIsLogedIn() {
                    self?.goWebView(url: TYOnlineUrlHelper.getProductDetailURL(product: product))
                } else {
                    self?.goLogin()
                }
            }
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYShopProductCell", for: indexPath) as! TYShopProductCell
            if let product = showProducts[safely: indexPath.row] {
                let parentVC = parent as? TYShopNativeVC
                let state = parentVC?.getBottomBtnState(productId: product.goodsId) ?? true
                cell.updateCell(product, bottomBtnState: state)
            }
            cell.sharedProductClosure = { [weak self] productId in
                self?.saveSharedId(productId)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Screen_IPadMultiply(130)
        } else if indexPath.section == 1 {
            return Screen_IPadMultiply(164)
        } else if indexPath.section == 2 {
            let type = TYUserInfoHelper.getUserType()
            if type == 2 {
                // 合伙人
                return Screen_IPadMultiply(260)
            } else {
                return Screen_IPadMultiply(230)
            }
        } else if indexPath.section == 3 {
            return Screen_IPadMultiply(210)
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0.01
        } else if section == 2 {
            return Screen_IPadMultiply(41)
        } else if section == 3 {
            return Screen_IPadMultiply(52)
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let headView = TYShopGoodHeadView()
            headView.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(41))
            return headView
        } else if section == 3 {
            typeHeadViewContent.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(52))
            if typeHeadView == nil {
                let headView = TYShopProductTypeView()
                headView.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(52))
                typeHeadViewContent.addSubview(headView)
                headView.platformTypeClosure = { [weak self] type in
                    self?.changeType(type)
                }
                typeHeadView = headView
            }
            typeHeadView?.updateSelected(type: type)
            return typeHeadViewContent
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 3 {
            return
        }
        if let product = showProducts[safely: indexPath.row] {
            if TYUserInfoHelper.userIsLogedIn() {
                goWebView(url: TYOnlineUrlHelper.getProductDetailURL(product: product))
            } else {
                goLogin()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let head = typeHeadView else { return }
        let offsetY = scrollView.contentOffset.y
        let headTargetH = typeHeadViewContent.frame.origin.y + typeHeadViewContent.frame.size.height
        if offsetY >= headTargetH {
            head.frame = CGRect(x: 0, y: Screen_NavItemY + Screen_IPadMultiply(58), width: Screen_Width, height: Screen_IPadMultiply(44))
            parent?.view.addSubview(head)
        } else {
            head.frame = typeHeadViewContent.bounds
            typeHeadViewContent.addSubview(head)
        }
    }
}

private extension TYShopRecommendVC {
    @objc func loginSuccess() {
        resetData()
    }
    
    @objc func logoutSuccess() {
        resetData()
    }
    
    func resetData() {
        requestExsRecommend()
        // 重置数据
        jdPageIndex = 1
        pddPageIndex = 1
        tbPageIndex = 1
        jdProducts.removeAll()
        pddProducts.removeAll()
        tbProducts.removeAll()
        requestSystemRecommend()
    }
}
