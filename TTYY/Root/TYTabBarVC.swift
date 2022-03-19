//
//  TYTabBarVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import BaseModule

class TYTabBarVC: UIViewController, YJSTabbarVCProtocol {
    
    var contentView = UIView()
    var tabBar = UIView()
    var barItems = [TYTabBarItem]()
    var subVCs = [Int: UIViewController]()
    
    /// 标记点击tabbar的时候，控制器是否需要执行js
    private var needRunJs = false
    /// 获取上一次的审核状态，加载tabbar
    private var launchCheckState = TYHuYanHelper.getCheckEnableState()
    
    private var firstInstallView = UIView()
    
    private var selelctIndex: Int {
        get {
            for index in 0 ..< barItems.count {
                if barItems[index].status == .Selected {
                    return index
                }
            }
            return 0
        }
        set {
            if newValue < barItems.count && barItems[newValue].status == .Selected {
                return
            }
            for index in 0 ..< barItems.count {
                if index == newValue {
                    barItems[index].status = .Selected
                } else {
                    barItems[index].status = .Normal
                }
            }
            
            guard let newVC = subVCAtIndex(newValue) else {
                return
            }
            if newVC.isKind(of: TYNavVC.self) {
                let tabNavVC = newVC as! TYNavVC
                tabNavVC.popToRootViewController(animated: true)
                isTabBarShow = true
            }
            turnToVC(newVC)
        }
    }
    
    @objc var isTabBarShow: Bool {
        get {
            return !tabBar.isHidden
        }
        set {
            tabBar.isHidden = !newValue
        }
    }
    //MARK: - 重载
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTabbarView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) == true {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        
        if let vcs = navigationController?.viewControllers, vcs.count > 1 {
            navigationController?.viewControllers = [vcs.last!]
        }
        
        createContentView()
        createTabBar()
        
        setupTabBarItem()
        setupDefaultData()
        ty_addObserver()
        createFirstInstallTip()
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
    //MARK: - UI创建
    func createContentView() {
        contentView = UIView.init()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    func createTabBar() {
        tabBar = UIView.init()
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(Screen_TabHeight)
        }
        tabBar.backgroundColor = UIColor.white
        let lineView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5))
        lineView.backgroundColor = Color_Hex(0xeeeeee)
        tabBar.addSubview(lineView)
    }
    
    func setupTabBarItem() {
        barItems = [TYTabBarItem]()
        
        let item0 = TYTabBarItem()
        item0.ty_setTitle("首页", forStatus: .Normal)
        item0.ty_setImage(UIImage(named: "tabBar_Icon0_unselected"), forStatus: .Normal)
        item0.ty_setImage(UIImage(named: "tabBar_Icon0_selected"), forStatus: .Selected)
        
        let item1 = TYTabBarItem()
        item1.ty_setTitle("优选", forStatus: .Normal)
        item1.ty_setImage(UIImage(named: "tabBar_Icon1_unselected"), forStatus: .Normal)
        item1.ty_setImage(UIImage(named: "tabBar_Icon1_selected"), forStatus: .Selected)

        let item2 = TYTabBarItem()
        item2.ty_setTitle("爆品", forStatus: .Normal)
        item2.ty_setImage(UIImage(named: "tabBar_Icon2_unselected"), forStatus: .Normal)
        item2.ty_setImage(UIImage(named: "tabBar_Icon2_selected"), forStatus: .Selected)
        
        let item3 = TYTabBarItem()
        item3.ty_setTitle("游戏", forStatus: .Normal)
        item3.ty_setImage(UIImage(named: "tabBar_Icon3_unselected"), forStatus: .Normal)
        item3.ty_setImage(UIImage(named: "tabBar_Icon3_selected"), forStatus: .Selected)

        let item4 = TYTabBarItem()
        item4.ty_setTitle("我的", forStatus: .Normal)
        item4.ty_setImage(UIImage(named: "tabBar_Icon4_unselected"), forStatus: .Normal)
        item4.ty_setImage(UIImage(named: "tabBar_Icon4_selected"), forStatus: .Selected)
        
        barItems.append(item0)
        barItems.append(item1)
        barItems.append(item2)
        if launchCheckState {
            barItems.append(item3)
        }
        barItems.append(item4)
        
        let itemWidth = UIScreen.main.bounds.width / (CGFloat)(barItems.count)
        var tempItem: TYTabBarItem?
        for index in 0 ..< barItems.count {
            let item = barItems[index]
            tabBar.addSubview(item)
            item.snp.makeConstraints { (make) in
                if tempItem != nil {
                    make.left.equalTo(tempItem!.snp.right)
                } else {
                    make.left.equalTo(tabBar)
                }
                make.top.equalTo(tabBar)
                make.size.equalTo(CGSize(width: itemWidth, height: 49.0))
            }
            item.tag = index
            tempItem = item
            item.onClickHandler = { (tabBarItem: TYTabBarItem) ->Void in
                if self.launchCheckState, tabBarItem.tag == 3, !TYUserInfoHelper.userIsLogedIn() {
                    let loginVC = TYLoginVC()
                    UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
                    return
                }
                self.selelctIndex = tabBarItem.tag
//                if tabBarItem.tag == 1, TYUserInfoHelper.userIsLogedIn() == false {
//                    let loginVC = TYLoginVC()
//                    UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
//                }
            }
        }
    }
    //MARK: - 方法
    @objc func subVCAtIndex(_ index: Int) -> UIViewController? {
        var subVC = subVCs[index]
        if subVC != nil {
            return subVC
        }
        switch index {
        case 0:
//            let vc = TYHomeVC(preLoad: true)
            let vc = TYHomeNativeVC()
            subVC = TYNavVC(rootViewController: vc)
        case 1:
//            let vc = TYShopVC(preLoad: true)
            let vc = TYShopNativeVC()
            subVC = TYNavVC(rootViewController: vc)
        case 2:
            let vc = TYExplosiveProductsController()
            subVC = TYNavVC(rootViewController: vc)
        case 3:
            if launchCheckState {
                let vc = TYGameVC(preLoad: true)
                subVC = TYNavVC(rootViewController: vc)
            } else {
                let vc = TYMineVC()
                subVC = TYNavVC(rootViewController: vc)
            }
        case 4:
            if launchCheckState {
                let vc = TYMineVC()
                subVC = TYNavVC(rootViewController: vc)
            }
        default:
            break
        }
        
        subVCs[index] = subVC
        return subVC
    }
    
    func setupDefaultData() {
        selelctIndex = 0
        needRunJs = true
        // 预加载所有跟控制器
        if !YJSReachbilityListener.isReachable() {
            return
        }
//        let _ = subVCAtIndex(1)
//        let _ = subVCAtIndex(2)
//        if TYUserInfoHelper.userIsLogedIn(), launchCheckState {
//            let _ = subVCAtIndex(3)
//        }
    }
    
    func turnToVC(_ newVC: UIViewController) {
        for vc in children {
            vc.removeFromParent()
            vc.view.removeFromSuperview()
        }
        
        addChild(newVC)
        didMove(toParent: newVC)
        contentView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name(TYNotificationSelectTabBarItemForIndex), object: ["itemIndex": self.selelctIndex])
        }
        
        if needRunJs {
            if let tabNavVC = newVC as? TYNavVC, let vc = tabNavVC.viewControllers.first, let baseVC = vc as? TYBaseVC {
                baseVC.runPageActionJS()
            }
        }
    }
    
    func refreshTabbarView() {
        for item in barItems {
            item.ty_refreshView()
        }
    }
    
    func setSubVC(_ subVC: UIViewController?, forIndex index: Int) {
        if subVC != nil {
            subVCs[index] = subVC
        }
        if selelctIndex == index {
            turnToVC(subVC!)
        }
    }
    
    @objc func setBadgeValue(_ value: Int, forIndex index: Int) {
        if index > barItems.count - 1 {
            return
        }
        let barItem = barItems[index]
        barItem.setBadgeValue(value)
    }
    
    @objc func currentVC() -> UIViewController? {
        return subVCs[selelctIndex]
    }
    
    func ty_addObserver() {
        // 监测通知：需要将tabbar的index改动到哪个
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeTabbarIndex), name: NSNotification.Name(rawValue: TYNotificationChangeTabBarItemForIndex), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func ty_popToRootController(index: Int) {
        guard let newVC = subVCAtIndex(index) else {
            return
        }
        if newVC.isKind(of: TYNavVC.self) {
            let tabNavVC = newVC as! TYNavVC
            tabNavVC.popToRootViewController(animated: true)
            isTabBarShow = true
        }
    }
    
    //MARK: - 事件
    @objc func handleChangeTabbarIndex(notification: Notification) {
        if let index =  notification.userInfo?["itemIndex"] as? Int, index >= 0 {
            if launchCheckState, index == 3, !TYUserInfoHelper.userIsLogedIn() {
                let loginVC = TYLoginVC()
                UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
                return
            }
            if index == 1, !TYUserInfoHelper.userIsLogedIn() {
                let loginVC = TYLoginVC()
                UIApplication.getCurrentVC()?.navigationController?.pushViewController(loginVC, animated: true)
            }
            if selelctIndex == index {
                ty_popToRootController(index: index)
            } else {
                selelctIndex = index
            }
        }
    }
    
    @objc func handleDidBecomeActive() {
        guard let codeStr = UIPasteboard.general.string, !codeStr.isBlank else { return }
        TYCopyProductHelper.requestSearch(tkl: codeStr)
    }
}

extension TYTabBarVC {
    func getSelectedIndex() -> Int {
        return selelctIndex
    }
}

extension TYTabBarVC: YJContainerControllerProtocol {
    @objc func selectedViewController() -> UIViewController? {
        currentVC()
    }
}

private extension TYTabBarVC {
    func createFirstInstallTip() {
        let firstInstall = TYCacheHelper.getCacheBool(for: kAppFirstInstallKey) ?? false
        if firstInstall {
            return
        }
        firstInstallView.backgroundColor = .white
        view.addSubview(firstInstallView)
        firstInstallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let imgV = UIImageView(image: UIImage.yjs_webpImage(imageName: "launch_second"))
        firstInstallView.addSubview(imgV)
        imgV.center = view.center
        
        let control = UIControl()
        control.addTarget(self, action: #selector(removeFirstInstallTip), for: .touchUpInside)
        firstInstallView.addSubview(control)
        control.snp.makeConstraints { make in
            make.bottom.equalTo(imgV).offset(Screen_IPadMultiply(-30))
            make.width.equalTo(imgV)
            make.height.equalTo(Screen_IPadMultiply(50))
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func removeFirstInstallTip() {
        firstInstallView.removeFromSuperview()
        TYCacheHelper.cacheBool(value: true, for: kAppFirstInstallKey)
        handleGuideView()
    }
    
    func handleGuideView() {
        let guideView = TYGuideView()
        view.addSubview(guideView)
        guideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
