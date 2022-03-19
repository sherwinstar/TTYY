//
//  TYShopSearchView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/9.
//

import UIKit
import BaseModule

class TYShopSearchView: UIView {
    
    var searchViewActionClosure: ((Bool, String)->Void)?
    
    private var serviceBtn = UIButton()
    private var searchTextField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYShopSearchView {
    func createSubviews() {
        backgroundColor = Color_Hex(0xF8F8F8)
        // 客服
        addSubview(serviceBtn)
        serviceBtn.setImage(UIImage(named: "mine_answer_icon"), for: .normal)
        serviceBtn.addTarget(self, action: #selector(serviceBtnClick), for: .touchUpInside)
        serviceBtn.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(53))
        }
        
        let bgView = UIView()
        bgView.backgroundColor = Color_Hex(0xECECEC)
        addSubview(bgView)
        bgView.layer.cornerRadius = Screen_IPadMultiply(6)
        bgView.layer.masksToBounds = true
        bgView.snp.makeConstraints { make in
            make.left.equalTo(serviceBtn.snp.right)
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-17))
            make.height.equalTo(Screen_IPadMultiply(34))
            make.centerY.equalToSuperview()
        }
        
        let searchIcon = UIImageView(image: UIImage(named: "history_search_icon"))
        bgView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(8))
            make.width.height.equalTo(Screen_IPadMultiply(26))
            make.centerY.equalToSuperview()
        }
        
        bgView.addSubview(searchTextField)
        searchTextField.font = Font_Medium_IPadMul(14)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "搜索或粘贴商品标题/链接".yjs_translateStr(), attributes: [.font: Font_System_IPadMul(14), .foregroundColor: Color_Hex(0x595959)])
        searchTextField.textColor = Color_Hex(0x262626)
        searchTextField.tintColor = Color_Hex(0x262626)
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
    }
    
    @objc func serviceBtnClick() {
        searchViewActionClosure?(false, "")
    }
}

extension TYShopSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let keyWord = textField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if !keyWord.isBlank {
            searchViewActionClosure?(true, keyWord)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
