//
//  TYHomeSearchView.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/31.
//

import UIKit
import BaseModule

class TYHomeSearchView: UIView {
    
    var textFieldBeginEditClosure: (()->Void)?
    var textFieldEndEditClosure: (()->Void)?
    var searchClosure: ((String?)->Void)?
    
    private var textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension TYHomeSearchView {
    func createSubviews() {
        backgroundColor = .white
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = Color_Hex(0xE11521).cgColor
        bgView.layer.cornerRadius = Screen_IPadMultiply(14)
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(Screen_IPadMultiply(30))
            make.right.equalTo(-Screen_IPadMultiply(30))
            make.centerX.equalToSuperview()
        }
        
        bgView.addSubview(textField)
        textField.font = Font_Medium_IPadMul(16)
        textField.attributedPlaceholder = NSAttributedString(string: "搜索或粘贴商品标题/链接".yjs_translateStr(), attributes: [.font: Font_System_IPadMul(16), .foregroundColor: Color_Hex(0xE11521)])
        textField.textColor = Color_Hex(0x595959)
        textField.tintColor = Color_Hex(0x595959)
        textField.returnKeyType = .search
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-40))
        }
        let searchBtn = UIButton()
        searchBtn.setImage(UIImage(named: "home_search_icon"), for: .normal)
        searchBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        bgView.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(36))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-7))
        }
    }
    
    @objc func searchAction() {
        let keyWord = textField.text
        searchClosure?(keyWord)
    }
}

extension TYHomeSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldBeginEditClosure?()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndEditClosure?()
    }
}
