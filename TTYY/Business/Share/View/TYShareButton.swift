//
//  TYShareButton.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/22.
//

import UIKit
import BaseModule

class TYShareButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: contentRect.size.height - Screen_IPadMultiply(20), width: contentRect.size.width, height: Screen_IPadMultiply(20))
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let x = (contentRect.size.width - Screen_IPadMultiply(50)) * 0.5
        return CGRect(x: x, y: 0, width: Screen_IPadMultiply(50), height: Screen_IPadMultiply(50))
    }
}
