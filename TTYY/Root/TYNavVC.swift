//
//  TYNavVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit

class TYNavVC: UINavigationController, UIGestureRecognizerDelegate {
    //MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) == true {
            interactivePopGestureRecognizer?.delegate = self
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
