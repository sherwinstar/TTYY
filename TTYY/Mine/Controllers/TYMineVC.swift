//
//  TYMineVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import BaseModule
import YJSWebModule

class TYMineVC: TYBaseVC {
    
    private var rebateInfo: TYRebateInfoModel?
    private var orderList: [TYOrderInfoModel]?
    
    private var noDataTipLb = UILabel()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        requestInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func requestInfo() {
        getRebateInfo()
        getOrderList()
    }
}

private extension TYMineVC {
    func getRebateInfo() {
        TYMineService.getUserRebateInfo { [weak self] isSuccess, infoModel in
            if let info = infoModel, isSuccess {
                self?.rebateInfo = info
                self?.tableView.reloadData()
            }
        }
    }
    
    func getOrderList() {
        TYMineService.getMineOrderList { [weak self] isSuccess, list in
            if let list = list, isSuccess {
                self?.orderList = list
                self?.tableView.reloadData()
            }
        }
    }
}

private extension TYMineVC {
    
    func setupSubviews() {
        view.backgroundColor = Color_Hex(0xF8F8F8)
        view.addSubview(tableView)
        tableView.backgroundColor = Color_Hex(0xF8F8F8)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Screen_TabHeight)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TYMineHeadCell.self, forCellReuseIdentifier: "TYMineHeadCell")
        tableView.register(TYInComeCell.self, forCellReuseIdentifier: "TYInComeCell")
        tableView.register(TYMineDetailCell.self, forCellReuseIdentifier: "TYMineDetailCell")
        tableView.register(TYOrderCell.self, forCellReuseIdentifier: "TYOrderCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NODataTipCellKey")
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedRowHeight = 0
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: NSNotification.Name(rawValue: TYNotificationLoginSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: Notification.Name(rawValue: TYNotificationLogoutSuccess), object: nil)
    }
    
    
    
    @objc func loginStateChange() {
        if TYUserInfoHelper.userIsLogedIn() {
            requestInfo()
        } else {
            rebateInfo = nil
            orderList = nil
            tableView.reloadData()
        }
    }
}

extension TYMineVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            let count = orderList?.count ?? 0
            return count > 3 ? 3 : 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if TYUserInfoHelper.userIsLogedIn() {
                return Screen_IPadMultiply(133) + Screen_NavItemY
            } else {
                return Screen_IPadMultiply(110) + Screen_NavItemY
            }
        } else if indexPath.section == 1 {
            let huYan = TYHuYanHelper.getCheckEnableState()
            if huYan {
                return Screen_IPadMultiply(255)
            } else {
                return Screen_IPadMultiply(160)
            }
        } else if indexPath.section == 2 {
            return Screen_IPadMultiply(100)
        }
        return Screen_IPadMultiply(153)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYMineHeadCell", for: indexPath) as! TYMineHeadCell
            let allMoney = rebateInfo?.allSaveMoney ?? 0
            cell.updateCell(allMoney)
            cell.headCellClosure = { [weak self] type in
                self?.handleHeadCell(type: type)
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYInComeCell", for: indexPath) as! TYInComeCell
            cell.updateCell(rebateInfo)
            cell.inComeClosure = { [weak self] type in
                self?.handleInComeCell(type: type)
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TYMineDetailCell", for: indexPath) as! TYMineDetailCell
            cell.detailClosure = { [weak self] type in
                self?.handleDetailCell(type: type)
            }
            cell.loadPartnerData()
            return cell
        } else if indexPath.section == 3 {
            if let list = orderList, list.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TYOrderCell", for: indexPath) as! TYOrderCell
                if indexPath.row < list.count {
                    let model = list[indexPath.row]
                    cell.updateCell(orderInfo: model)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NODataTipCellKey", for: indexPath)
                cell.contentView.backgroundColor = Color_Hex(0xF8F8F8)
                noDataTipLb.text = "暂无下单记录"
                noDataTipLb.textColor = Color_Hex(0x999999)
                noDataTipLb.textAlignment = .center
                noDataTipLb.font = Font_System_IPadMul(14)
                cell.contentView.addSubview(noDataTipLb)
                noDataTipLb.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return Screen_IPadMultiply(30)
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 {
            let header = UIView()
            header.backgroundColor = Color_Hex(0xF8F8F8)
            header.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(30))
            let tipLb = UILabel()
            tipLb.font = Font_Medium_IPadMul(16)
            tipLb.textColor = Color_Hex(0x262626)
            tipLb.text = "最近下单"
            header.addSubview(tipLb)
            tipLb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(Screen_IPadMultiply(17))
                make.top.bottom.equalToSuperview()
            }
            return header
        }
        return nil
    }
}

private extension TYMineVC {
    func handleHeadCell(type: HeadCellActionType) {
        switch type {
        case .setting:
            let vc = TYSettingVC()
            navigationController?.pushViewController(vc, animated: true)
        case .customer:
            let vc = TYContactUsVC()
            navigationController?.pushViewController(vc, animated: true)
        case .login:
            goLogin()
        case .bindCode:
            let bindVC = TYBindInviteCodeVC()
            navigationController?.pushViewController(bindVC, animated: true)
        case .copyUserId:
            let userId = TYUserInfoHelper.getUserId()
            let pasteboard = UIPasteboard.general
            pasteboard.string = userId
            showToast(msg: "已复制")
        }
    }
    
    func goLogin() {
        let vc = TYLoginVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goGame() {
        if TYHuYanHelper.getCheckEnableState() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 3])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil, userInfo: ["itemIndex": 1])
        }
    }
    
    func handleInComeCell(type: InComeActionType) {
        switch type {
        case .login:
            goLogin()
        case .goGame:
            goGame()
        case .drawMoney:
            let vc = TYWithdrawVC()
            navigationController?.pushViewController(vc, animated: true)
        case .drawShell:
            goWebView(url: TYOnlineUrlHelper.getShellExchangeURL())
        }
    }
    
    func handleDetailCell(type: DetailActionType) {
        switch type {
        case .login:
            goLogin()
        case .order:
            goWebView(url: TYOnlineUrlHelper.getOrderListURL())
        case .detail:
            goWebView(url: TYOnlineUrlHelper.getTransactionRecordsURL())
        case .collect:
            goWebView(url: TYOnlineUrlHelper.getCollectionURL())
        case .partner:
            goPartnerWebView()
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
    
    func goPartnerWebView() {
        let urlStr = TYOnlineUrlHelper.getPartner()
        let partnerWebVC = YJSWebStoreVC()
        partnerWebVC.originUrl = urlStr
        partnerWebVC.webVC.needEncode = false
        partnerWebVC.webVC.topMargin = Screen_NavItemY
        partnerWebVC.setupHiddenNav()
        navigationController?.pushViewController(partnerWebVC, animated: true)
    }
}
