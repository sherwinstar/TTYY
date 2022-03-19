//
//  YJSReqPollHostService.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation
import RxCocoa
import RxSwift

class YJSReqPollHostService: NSObject, YJSReqPollHostServiceProtocol {
    static func singleton() -> Bool {
        return false
    }
    
    static func share() -> Self {
        return YJSReqPollHostService() as! Self
    }
    //域名配置
    private var dicHostConfig = [YJSRequestHostType: YJSReqHostModel]()
    
    required override init() {
        super.init()
        
        _ = NotificationCenter.default.rx
        .notification(NSNotification.Name(rawValue: "kZSUmengOnlineParametersChangedNotification"))
        .takeUntil(self.rx.deallocated)
        .subscribe(onNext: { [weak self] (_) in
            self?.updateOnOnlineParamsChanged()
        })
    }
    
    //设置各个域名的备用域名
    func update(_ hosts: [String]?, forHostType type: YJSRequestHostType) {
        guard let hosts = hosts else {
            return
        }
        let hostModel = getHostModel(forType: type)
        if hostModel.isSupportPolls == false {
            return
        }
        hostModel.pollHosts = [String]()
        for host in hosts {
            if let url = URL(string: host), let hostStr = url.host {
                hostModel.pollHosts.append(hostStr)
            } else {
                hostModel.pollHosts.append(host)
            }
        }
    }
    
    /// 更新所有的备用域名，在线参数获取的时候调用
    func updateOnOnlineParamsChanged() {
        #if TARGET_ZSSQ
        update(YJSOnlineParamsHelper.shared.params?.apiUrls, forHostType: .api)
        update(YJSOnlineParamsHelper.shared.params?.searchUrls, forHostType: .b)
        update(YJSOnlineParamsHelper.shared.params?.bookApiUrls, forHostType: .bookApi)
        update(YJSOnlineParamsHelper.shared.params?.internalChapterUrlsNew, forHostType: .chapter2)
        #elseif TARGET_FTZS
        update(FTZSOnlineParamsHelper.shared.params?.apiUrls, forHostType: .api)
        update(FTZSOnlineParamsHelper.shared.params?.bUrls, forHostType: .b)
        update(FTZSOnlineParamsHelper.shared.params?.bookApiUrls, forHostType: .bookApi)
        update(FTZSOnlineParamsHelper.shared.params?.chapterUrls, forHostType: .chapter2)
        #endif
        
    }
    
    func getHostModel(forType hostType: YJSRequestHostType) -> YJSReqHostModel {
        let reqHost = dicHostConfig[hostType]
        if let unwarp = reqHost {
            return unwarp
        }
        let hostModel = YJSReqHostModel(hostType)
        dicHostConfig[hostType] = hostModel
        return hostModel
    }
    
    func pollNext(forType hostType: YJSRequestHostType) {
        let hostModel = getHostModel(forType: hostType)
        guard hostModel.isSupportPolls else {
            return
        }
        
        guard hostModel.pollHosts.count > 0 else {
            return
        }
        
        let curHost = hostModel.curHostString()
        guard let curIndex = hostModel.pollHosts.firstIndex(of: curHost) else {
            return
        }
        do {
            var newHost: String?
            if curIndex + 1 >= hostModel.pollHosts.count {
                newHost = hostModel.pollHosts.first
            } else {
                newHost = hostModel.pollHosts[curIndex + 1]
            }
            guard let host = newHost else {
                return
            }
            //保存新的选中域名
            try hostModel.hostConfigCache.setObject(host, forKey: hostType.rawValue)
        } catch {
            return
        }
    }
}
