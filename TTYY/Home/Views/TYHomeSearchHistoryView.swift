//
//  TYHomeSearchHistoryView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/7.
//

import UIKit
import BaseModule

class TYHomeSearchHistoryView: UIView {
    
    var searchClosure: ((String?)->Void)?
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        return table
    }()
    
    private var keywords = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        refreshData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshData() {
        let keys = TYCacheHelper.getHistoryKeyWordArray(for: kSaveSearchKeyWordHistoryKey)
        if let array = keys, array.count > 0 {
            keywords = array
        } else {
            keywords.removeAll()
        }
        tableView.reloadData()
        tableView.contentOffset = .zero
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        if view.isKind(of: UITableView.self) {
            return self
        }
        return view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

private extension TYHomeSearchHistoryView {
    func createSubviews() {
        backgroundColor = .white
        
        let tipLb = UILabel()
        tipLb.backgroundColor = Color_Hex(0xF5F5F5)
        tipLb.font = Font_System_IPadMul(12)
        tipLb.text = "  输入品牌/型号/款式等关键词，快速找到商品"
        tipLb.textColor = Color_Hex(0x777777)
        tipLb.layer.cornerRadius = Screen_IPadMultiply(4)
        tipLb.layer.masksToBounds = true
        addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(315))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(8))
            make.centerX.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(27))
        }
        
        addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.snp.makeConstraints { make in
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(8))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-300 + Screen_TabHeight))
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TYSearchHistoryCell.self, forCellReuseIdentifier: "TYSearchHistoryCell")
       
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedRowHeight = 0
        }
    }
}

extension TYHomeSearchHistoryView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TYSearchHistoryCell", for: indexPath) as! TYSearchHistoryCell
        let title = keywords[indexPath.row]
        cell.updateTitle(title)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Screen_IPadMultiply(42)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if keywords.count > 0 {
            return Screen_IPadMultiply(58)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if keywords.count <= 0 {
            return nil
        }
        let view = UIView()
        view.backgroundColor = .white
        let clearBtn = UIButton()
        clearBtn.setTitleColor(Color_Hex(0x999999), for: .normal)
        clearBtn.setTitle("清除历史", for: .normal)
        clearBtn.titleLabel?.font = Font_System_IPadMul(14)
        view.addSubview(clearBtn)
        clearBtn.addTarget(self, action: #selector(clearBtnClick), for: .touchUpInside)
        clearBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keywords[indexPath.row]
        searchClosure?(key)
    }
    
    @objc func clearBtnClick() {
        let clearView = TYClearHistoryView()
        var contentWindow = UIApplication.shared.keyWindow
        let windows = UIApplication.shared.windows
        if let keyboardWindow = NSClassFromString("UIRemoteKeyboardWindow")  {
            for window in windows {
                if window.isKind(of: keyboardWindow) {
                    contentWindow = window
                }
            }
        }
        contentWindow?.addSubview(clearView)
        clearView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        clearView.clearHistoryClosure = { [weak self] in
            self?.refreshData()
        }
    }
}
