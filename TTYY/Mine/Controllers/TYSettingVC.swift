//
//  TYSettingVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/5.
//

import UIKit
import BaseModule
import YJSWebModule

class TYSettingVC: TYBaseVC {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    
    /// 退出登录按钮
    private lazy var logoutBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("退出账号", for: .normal)
        btn.setTitleColor(Color_Hex(0x999999), for: .normal)
        btn.titleLabel?.font = Font_Medium_IPadMul(18)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = Color_Hex(0x999999).cgColor
        btn.layer.cornerRadius = Screen_IPadMultiply(12)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private var dataArray = ["提现设置", "联系客服", "关于我们", "注销账号"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubView()
    }
}

private extension TYSettingVC {
    func createSubView() {
        setupNavBar(title: "设置")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_NavHeight)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TYSettingCell.self, forCellReuseIdentifier: "TYSettingCell")
        
        let versionLb = UILabel()
        versionLb.textColor = Color_Hex(0x999999)
        versionLb.font = Font_System_IPadMul(14)
        versionLb.text = "version " + UIApplication.yjs_versionShortCode()
        versionLb.textAlignment = .center
        view.addSubview(versionLb)
        versionLb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Screen_SafeBottomHeight - Screen_IPadMultiply(26))
        }
        
        view.addSubview(logoutBtn)
        logoutBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(192), height: Screen_IPadMultiply(52)))
            make.bottom.equalTo(versionLb.snp.top).offset(Screen_IPadMultiply(-10))
            make.centerX.equalToSuperview()
        }
        logoutBtn.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        refreshLogoutBtn()
        tableView.reloadData()
    }
    
    func refreshLogoutBtn() {
        if TYUserInfoHelper.userIsLogedIn() {
            logoutBtn.isHidden = false
        } else {
            logoutBtn.isHidden = true
        }
    }
}

extension TYSettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TYSettingCell", for: indexPath) as! TYSettingCell
        let titleStr = dataArray[safely: indexPath.row] ?? ""
        cell.updateCell(titleStr: titleStr)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Screen_IPadMultiply(52)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            withdrawSetting()
        case 1:
            contactUS()
        case 2:
            aboutUS()
        case 3:
            closeAccount()
        default:
            break
        }
    }
}

// MARK: - 处理点击事件
private extension TYSettingVC {
    
    /// 提现设置
    func withdrawSetting() {
        if !TYUserInfoHelper.userIsLogedIn() {
            let vc = TYLoginVC()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let aliPayVC = TYAliPaySettingVC()
        navigationController?.pushViewController(aliPayVC, animated: true)
    }
    
    /// 联系我们
    func contactUS() {
        let vc = TYContactUsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 关于我们
    func aboutUS() {
        let vc = TYAboutUsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 注销账号
    func closeAccount() {
        let vc = TYProtocolVC(type: .closeAccount)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 退出账号
    @objc func logoutAction() {
        TYUserInfoHelper.removeUserInfo()
        refreshLogoutBtn()
    }
}

extension TYSettingVC: TYLoginVCProtocol {
    func loginVCClose(_ loginVC: TYLoginVC) {}
    
    func loginVC(_ loginVC: TYLoginVC, loginFinished state: Bool) {
        if state {
            refreshLogoutBtn()
        }
    }
}
