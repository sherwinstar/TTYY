//
//  TYBaseVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import BaseModule

class TYBaseVC: YJSBaseVC {

    var navBarView = TYNavBarView()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ty_hideNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ty_hideNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let count = navigationController?.viewControllers.count
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (count! > 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
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
    
    fileprivate func ty_hideNavBar() {
        let count = navigationController?.viewControllers.count
        let isKind = navigationController?.parent?.isKind(of: TYTabBarVC.self)
        
        if (isKind != nil && isKind!) {
            let parent = navigationController?.parent as! TYTabBarVC
            parent.isTabBarShow = (count == 1)
        }
    }
    
    func ty_setupNavBarView() {
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view);
            make.height.equalTo(Screen_NavHeight);
        }
        
        navBarView.ty_adjustLeftItem(backTitle: "", backArrow: true) {[weak self] (_) in
            if self?.navigationController?.viewControllers.last == self {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    open func hideNavBar(navBarHidden: Bool) {
        navBarView.isHidden = navBarHidden
    }
    
    func runPageActionJS() {
        
    }
}

extension UIViewController {
    @objc func ty_navVC() -> UINavigationController? {
        if isKind(of: UINavigationController.self) {
            return self as? UINavigationController
        } else {
            if isKind(of: UITabBarController.self) {
                return (self as! UITabBarController).selectedViewController?.ty_navVC()
            } else {
                return navigationController
            }
        }
    }
}
