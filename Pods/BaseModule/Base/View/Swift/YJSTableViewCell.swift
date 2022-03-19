//
//  YJSTableViewCell.swift
//  YouShaQi
//
//  Created by Beginner on 2020/7/20.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import UIKit

open class YJSTableViewCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSelectedView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelectedView() {
        contentView.backgroundColor = .white
        selectedBackgroundView = UIView(frame: bounds)
        selectedBackgroundView?.backgroundColor = Color_HexA(0xF0F0F5, alpha: 0.39)
    }
}
