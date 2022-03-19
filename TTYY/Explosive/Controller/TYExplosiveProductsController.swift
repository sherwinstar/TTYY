//
//  TYExplosiveProductsController.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/2.
//

import UIKit
import BaseModule
import YJSWebModule
import MJRefresh

class TYExplosiveProductsController: TYBaseVC {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var header: TYExplosiveHeader = {
        let header = TYExplosiveHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  Screen_IPadMultiply(127)))
        return header
    }()
    var types :[TYShopRecommendType]?
    var goodsType = 0
    var recomendedProducts = [TYShopProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        requestRecommendType()
        // Do any additional setup after loading the view.
    }
}

private extension TYExplosiveProductsController {
    func createSubviews() {
        view.backgroundColor = Color_Hex(0xF8F8F8)
        self.view.addSubview(header)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(107 + Screen_NavItemY)
            make.bottom.equalTo(-Screen_TabHeight)
        }
        header.explosiveClickClosure =  { [weak self] type in
            self?.goodsType = type
            self?.requestRecommend()
        }
        tableView.backgroundColor = Color_Hex(0xF8F8F8)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TYExplosiveProductCell.self, forCellReuseIdentifier: "TYExplosiveProductCell")
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

private extension TYExplosiveProductsController {
    /// 请求爆款商品
    func requestRecommendType() {
        TYExplosiveService.requestRecommendType { [weak self] isSuccess, types in
            if types == nil || types?.count == 0 {
                return
            }
            self?.types = types
            self?.goodsType = types!.first!.id
            self?.header.loadData(types)
            self?.requestRecommend()
        }
    }
    
    /// 请求推荐商品（请求第一页商品）
    func requestRecommend() {
        showProgress()
        TYExplosiveService.requestRecommend(goodsType: goodsType) { [weak self] isSuccess, products in
            self?.hideProgress()
            self?.handleRecommend(isSuccess, products: products)
        }
    }
    
    func handleRecommend(_ isSuccess: Bool, products: [TYShopProductModel]?) {
        if let models = products, isSuccess {
            recomendedProducts.removeAll()
            recomendedProducts += models
            tableView.reloadData()
            if (recomendedProducts.count > 0) {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
}

private extension TYExplosiveProductsController {
    @objc func loginSuccess() {
        resetData()
    }
    
    @objc func logoutSuccess() {
        resetData()
    }
    
    func resetData() {
        // 重置数据
        recomendedProducts.removeAll()
        requestRecommendType()
    }
    func goWebView(url: String) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        self.navigationController?.pushViewController(web, animated: true)
    }
    
    func goLogin() {
        let vc = TYLoginVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TYExplosiveProductsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recomendedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TYExplosiveProductCell", for: indexPath) as! TYExplosiveProductCell
        if let product = recomendedProducts[safely: indexPath.row] {
            let parentVC = parent as? TYShopNativeVC
            let state = parentVC?.getBottomBtnState(productId: product.goodsId) ?? true
            cell.updateCell(product, bottomBtnState: state)
        }
//            cell.sharedProductClosure = { [weak self] productId in
//                self?.saveSharedId(productId)
//            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Screen_IPadMultiply(175)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = recomendedProducts[safely: indexPath.row] {
            if TYUserInfoHelper.userIsLogedIn() {
                goWebView(url: TYOnlineUrlHelper.getProductDetailURL(product: product))
            } else {
                goLogin()
            }
        }
    }
}
