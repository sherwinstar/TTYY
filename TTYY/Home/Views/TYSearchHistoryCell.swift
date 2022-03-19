//
//  TYSearchHistoryCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/7.
//

import UIKit
import BaseModule

class TYSearchHistoryCell: UITableViewCell {
    
    private var titleLb = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTitle(_ title: String) {
        titleLb.text = title
    }
}

private extension TYSearchHistoryCell {
    func createSubviews() {
        let searchIcon = UIImageView(image: UIImage(named: "history_search_icon"))
        contentView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(24))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(4))
            make.width.height.equalTo(Screen_IPadMultiply(34))
        }
        
        let goIcon = UIImageView(image: UIImage(named: "history_go_icon"))
        contentView.addSubview(goIcon)
        goIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-24))
            make.width.height.top.equalTo(searchIcon)
        }
        
        contentView.addSubview(titleLb)
        titleLb.font = Font_System_IPadMul(16)
        titleLb.textColor = Color_Hex(0x595959)
        titleLb.textAlignment = .left
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(Screen_IPadMultiply(4))
            make.right.equalTo(goIcon.snp.left).offset(Screen_IPadMultiply(-4))
            make.centerY.equalTo(searchIcon)
        }
    }
}
