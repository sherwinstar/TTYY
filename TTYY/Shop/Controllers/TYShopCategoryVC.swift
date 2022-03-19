//
//  TYShopCategoryVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule
import YJSWebModule
import MJRefresh

class TYShopCategoryVC: TYBaseVC {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        return table
    }()
    
    private var tool = TYShopCategoryTool()
    
    private var info: TYBaseConfigModel?
    
    private var sortName: String = "goodComments"
    private var sort: String = "desc"
    
    private var products = [TYShopProductModel]()
    
    private var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTool()
        createTableView()
    }
    
    func updateCategory(_ info: TYBaseConfigModel) {
        self.info = info
        sortName = "goodComments"
        sort = "desc"
        tool.resetState()
        tableView.setContentOffset(.zero, animated: true)
        products.removeAll()
        requestProduct()
        addObserver()
    }
}

private extension TYShopCategoryVC {
    func createTool() {
        view.addSubview(tool)
        tool.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(40))
        }
        tool.filterClosure = { [weak self] sortName, sort in
            self?.sortName = sortName
            self?.sort = sort
            self?.products.removeAll()
            self?.pageIndex = 1
            self?.tableView.setContentOffset(.zero, animated: true)
            self?.requestProduct()
        }
    }
    
    func createTableView() {
        view.backgroundColor = Color_Hex(0xF8F8F8)
        
        view.addSubview(tableView)
        tableView.backgroundColor = Color_Hex(0xF8F8F8)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tool.snp.bottom)
        }
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
    
    func saveSharedId(_ productId: String) {
        let parentVC = parent as? TYShopNativeVC
        parentVC?.saveSharedId(productId)
    }
    
    func goLogin() {
        let vc = TYLoginVC()
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension TYShopCategoryVC {
    func requestProduct() {
        guard let model = info, let key = Int(model.key) else { return }
        showProgress()
        tableView.mj_footer?.resetNoMoreData()
        TYShopService.requestJingfenSearch(key: key, pageIndex: 1, sortName: sortName, sort: sort) { [weak self] isSuccess, models in
            self?.hideProgress()
            if let infos = models {
                self?.products = infos
                self?.addRefreshFooter()
            }
            self?.tableView.reloadData()
        }
    }
    
    func addRefreshFooter() {
        if tableView.mj_footer == nil {
            tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(requestMoreProduct))
        }
    }
    
    @objc func requestMoreProduct() {
        guard let model = info, let key = Int(model.key) else { return }
        showProgress()
        TYShopService.requestJingfenSearch(key: key, pageIndex: pageIndex + 1, sortName: sortName, sort: sort) { [weak self] isSuccess, models in
            self?.hideProgress()
            self?.tableView.mj_footer?.endRefreshing()
            if let infos = models, var productModels = self?.products {
                productModels += infos
                self?.products = productModels
                self?.pageIndex += 1
            }
            if isSuccess, models == nil {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self?.tableView.reloadData()
        }
    }
}

extension TYShopCategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TYShopProductCell", for: indexPath) as! TYShopProductCell
        if let product = products[safely: indexPath.row] {
            let parentVC = parent as? TYShopNativeVC
            let state = parentVC?.getBottomBtnState(productId: product.goodsId) ?? true
            cell.updateCell(product, bottomBtnState: state)
        }
        cell.sharedProductClosure = { [weak self] productId in
            self?.saveSharedId(productId)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Screen_IPadMultiply(215)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = products[safely: indexPath.row] {
            if TYUserInfoHelper.userIsLogedIn() {
                let web = YJSWebStoreVC()
                web.originUrl = TYOnlineUrlHelper.getProductDetailURL(product: product)
                web.webVC.needEncode = false
                web.webVC.topMargin = Screen_NavItemY
                web.setupHiddenNav()
                parent?.navigationController?.pushViewController(web, animated: true)
            } else {
                goLogin()
            }
        }
    }
}

private extension TYShopCategoryVC {
    @objc func loginSuccess() {
        resetData()
    }
    
    @objc func logoutSuccess() {
        resetData()
    }
    
    func resetData() {
        pageIndex = 1
        requestProduct()
    }
}

