//
//  UIButton+Extension.swift
//  BaseModule
//
//  Created by Beginner on 2020/9/25.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    public func setBackgroundColor(_ bgColor: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.yjs_image(color: bgColor, size: CGSize(width: 1, height: 1)), for: state)
    }
}
