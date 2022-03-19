//
//  TTYYBaseVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit

class TYBaseVC: YJSBaseVC {

    var navBarView = TYNavBarView()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ftzs_hideNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ftzs_hideNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let count = self.navigationController?.viewControllers.count
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (count! > 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .white
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
    
    fileprivate func ftzs_hideNavBar() {
        let count = self.navigationController?.viewControllers.count
        let isKind = self.navigationController?.parent?.isKind(of: FTZSTabBarVC.self)
        
        if (isKind != nil && isKind!) {
            let parent = self.navigationController?.parent as! FTZSTabBarVC
            parent.isTabBarShow = (count == 1)
        }
    }
    
    func ftzs_setupNavBarView() {
        self.view.addSubview(self.navBarView)
        self.navBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view);
            make.height.equalTo(Screen_NavHeight);
        }
        
        self.navBarView.ftzs_adjustLeftItem(backTitle: "返回", backArrow: true) {[weak self] (index) in
            if self?.navigationController?.viewControllers.last == self {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    open func hideNavBar(navBarHidden: Bool) {
        self.navBarView.isHidden = navBarHidden
    }
}

extension UIViewController {
    @objc func ftzs_navVC() -> UINavigationController? {
        if self.isKind(of: UINavigationController.self) {
            return self as? UINavigationController
        } else {
            if self.isKind(of: UITabBarController.self) {
                return (self as! UITabBarController).selectedViewController?.ftzs_navVC()
            } else {
                return self.navigationController
            }
        }
    }
}
