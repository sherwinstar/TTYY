//
//  YJSAlert.swift
//  BaseModule
//
//  Created by Admin on 2020/9/7.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit

public struct YJSAlert {
    /// 包装系统的 alert：只有一个取消按钮的alert
    public static func showAlert(in parentVC: UIViewController, title: String?, msg: String?, cancelTitle: String = "取消", cancelClosure: ((UIAlertAction) -> Void)? = nil) {
        showAlert(in: parentVC, title: title, msg: msg, cancelTitle: cancelTitle, cancelClosure: cancelClosure, confirmTitle: nil, confirmClosure: nil)
    }
    
    /// 包装系统的 alert：有两个按钮，一个取消，一个确定的 alert
    public static func showAlert(in parentVC: UIViewController, title: String?, msg: String?, cancelTitle: String?, cancelClosure: ((UIAlertAction) -> Void)?, confirmTitle: String?, confirmClosure: ((UIAlertAction) -> Void)?) {
        doInMain {        
            let alert = YJSAlertController(title: title, message: msg, preferredStyle: .alert)
            if let cancel = cancelTitle {
                alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: cancelClosure))
            }
            if let confirm = confirmTitle {
                alert.addAction(UIAlertAction(title: confirm, style: .default, handler: confirmClosure))
            }
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
}

open class YJSAlertController: UIAlertController {
    open override var shouldAutorotate: Bool {
        false
    }
}
