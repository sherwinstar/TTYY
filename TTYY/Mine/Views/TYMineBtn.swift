//
//  TYMineBtn.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//

import UIKit
import BaseModule

class TYMineBtn: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let y = (contentRect.size.height - Screen_IPadMultiply(48) - Screen_IPadMultiply(20)) * 0.5 + Screen_IPadMultiply(48)
        return CGRect(x: 0, y: y, width: contentRect.size.width, height: Screen_IPadMultiply(20))
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let x = (contentRect.size.width - Screen_IPadMultiply(48)) * 0.5
        let y = (contentRect.size.height - Screen_IPadMultiply(48) - Screen_IPadMultiply(20)) * 0.5
        return CGRect(x: x, y: y, width: Screen_IPadMultiply(48), height: Screen_IPadMultiply(48))
    }

}
