//
//  YJSNavVC.swift
//  YouShaQi
//
//  Created by Beginner on 2019/7/30.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation

public class YJSNavVC: UINavigationController, UIGestureRecognizerDelegate {
    //MARK: - 重载
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) == true {
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
}
