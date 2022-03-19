//
//  TYSettingCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/6.
//

import UIKit
import BaseModule

class TYSettingCell: UITableViewCell {
    private lazy var titleLb: UILabel = {
        let label = UILabel()
        label.font = Font_System_IPadMul(14)
        label.textColor = Color_Hex(0x262626)
        return label
    }()
    
    private lazy var arrowImg = UIImageView(image: UIImage(named: "setting_more_icom"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(titleStr: String) {
        titleLb.text = titleStr.yjs_translateStr()
    }
 
    private func createSubViews() {
        selectionStyle = .none
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(arrowImg)
        arrowImg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-20))
            make.centerY.equalToSuperview()
        }
    }
}
