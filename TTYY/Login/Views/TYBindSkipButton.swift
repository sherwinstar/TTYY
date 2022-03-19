//
//  TYBindSkipButton.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/8.
//

import UIKit
import BaseModule

class TYBindSkipButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: contentRect.size.width - Screen_IPadMultiply(12), height: contentRect.size.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let x = contentRect.size.width - Screen_IPadMultiply(12)
        let y = (contentRect.size.height - Screen_IPadMultiply(20)) * 0.5
        return CGRect(x: x, y: y, width: Screen_IPadMultiply(12), height: Screen_IPadMultiply(20))
    }
}
