//
//  UILabel+Extension.swift
//  YouShaQi
//
//  Created by YJPRO on 2020/2/19.
//  Copyright © 2020 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation

extension UILabel {
    public class func create(text: String?, textColor: UIColor, font: UIFont?, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text?.yjs_translateStr()
        label.textColor = textColor
        label.textAlignment = alignment
        if let font = font {
            label.font = font
        }
        return label
    }
}
