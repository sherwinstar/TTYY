//
//  YJSSTA.swift
//  BaseApp
//
//  Created by Admin on 2020/7/16.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import SensorsAnalyticsSDK

public struct YJSSTA {
    public func setUserProfile(_ profile: Any?, for key: String?) {
        if let key = key, let profile = profile {
            SensorsAnalyticsSDK.sharedInstance()?.set(key, to: profile)
        }
    }

    public func track(eventName: String?, properties: NSDictionary?) {
        if let event = eventName, !event.isEmpty {
            if let properties = properties as? [String : Any], properties.count != 0 {
                SensorsAnalyticsSDK.sharedInstance()?.track(event, withProperties: properties)
            } else {
                SensorsAnalyticsSDK.sharedInstance()?.track(event)
            }
        }
    }

    public func track(viewScreen: UIViewController?, properties: NSDictionary?) {
        if let vc = viewScreen {
            if let properties = properties as? [String : Any], properties.count != 0 {
                SensorsAnalyticsSDK.sharedInstance()?.trackViewScreen(vc, properties: properties)
            } else {
                SensorsAnalyticsSDK.sharedInstance()?.trackViewScreen(vc)
            }
        }
    }

    public func track(view: UIView?, properties: NSDictionary?) {
        if let view = view {
            if let properties = properties as? [String : Any], properties.count != 0 {
                SensorsAnalyticsSDK.sharedInstance()?.trackViewAppClick(view, withProperties: properties)
            } else {
                SensorsAnalyticsSDK.sharedInstance()?.trackViewAppClick(view)
            }
        }
    }
}
