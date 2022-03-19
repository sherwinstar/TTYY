//
//  TYLaunchScreenSplashBgImgVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/14.
//

import UIKit

let kTYLaunchScreenSplashBgImgID = "LaunchScreenSplashBgImgID1"
let kTYLaunchScreenSplashBgImgIDKey = "kTYLaunchScreenSplashBgImgIDKey"

class TYLaunchScreenSplashBgImgVC: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TYCacheHelper.cacheString(value: kTYLaunchScreenSplashBgImgID, for: kTYLaunchScreenSplashBgImgIDKey)
    }
}
