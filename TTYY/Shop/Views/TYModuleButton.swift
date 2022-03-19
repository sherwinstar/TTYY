//
//  TYModuleButton.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

class TYModuleButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageWH = Screen_IPadMultiply(42)
        let x = (contentRect.size.width - imageWH) * 0.5
        let y: CGFloat = 0
        return CGRect(x: x, y: y, width: imageWH, height: imageWH)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleH = Screen_IPadMultiply(17)
        let y = contentRect.size.height - titleH
        return CGRect(x: 0, y: y, width: contentRect.size.width, height: titleH)
    }
}
