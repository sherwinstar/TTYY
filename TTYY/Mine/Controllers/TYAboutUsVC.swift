//
//  TYAboutUsVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/6.
//

import UIKit
import BaseModule

class TYAboutUsVC: TYBaseVC {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    
    private var dataArray = ["用户协议", "隐私保护政策", "第三方SDK合作伙伴共享信息说明"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
}

private extension TYAboutUsVC {
    func createSubviews() {
        setupNavBar(title: "关于我们")
        let logoImg = UIImageView(image: UIImage(named: "about_us_logo"))
        view.addSubview(logoImg)
        logoImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(54) + Screen_NavHeight)
            make.centerX.equalToSuperview()
        }
        
        let versonLb = UILabel()
        versonLb.font = Font_System_IPadMul(14)
        versonLb.textColor = Color_Hex(0x999999)
        versonLb.text = "version " + UIApplication.yjs_versionShortCode()
        versonLb.textAlignment = .center
        view.addSubview(versonLb)
        versonLb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(logoImg.snp.bottom).offset(Screen_IPadMultiply(11))
        }
        
        let copyRightLb = UILabel()
        copyRightLb.font = Font_System_IPadMul(14)
        copyRightLb.textColor = Color_Hex(0x999999)
        copyRightLb.text = "copyright© 江西聚文有限公司".yjs_translateStr()
        copyRightLb.textAlignment = .center
        view.addSubview(copyRightLb)
        copyRightLb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Screen_SafeBottomHeight - Screen_IPadMultiply(26))
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(copyRightLb.snp.top).offset(-Screen_IPadMultiply(72))
            make.height.equalTo(Screen_IPadMultiply(156))
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TYSettingCell.self, forCellReuseIdentifier: "TYSettingCell")
        tableView.reloadData()
    }
}

extension TYAboutUsVC: UITableViewDataSource, UITableViewDelegate {
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
        var type: ProtocolType = .userAgreement
        switch indexPath.row {
        case 0:
            type = .userAgreement
        case 1:
            type = .privacyPolicy
        case 2:
            type = .thirdSDK
        default:
            break
        }
        goProtocolVC(type: type)
    }
}

private extension TYAboutUsVC {
    func goProtocolVC(type: ProtocolType) {
        let vc = TYProtocolVC(type: type)
        navigationController?.pushViewController(vc, animated: true)
    }
}
