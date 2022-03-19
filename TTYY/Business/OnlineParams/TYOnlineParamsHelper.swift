//
//  TYOnlineParamsHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/19.
//

import UIKit
import Cache
import BaseModule

class TYOnlineParamsHelper: NSObject {
    
    var onlineParamsModel: TYOnlineParamsModel? {
        get {
            onlineParamsPrivate
        }
    }
    
    private var onlineParamsPrivate: TYOnlineParamsModel?
    
    private var lock: NSLock = NSLock()
    
    private lazy var modelCache : Storage<TYOnlineParamsModel> = {
        let diskConfig = DiskConfig(name: "com.ttyy.onlineParams")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let modelCache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: TYOnlineParamsModel.self))
        return modelCache
    }()
    
    private let modelSaveKey = "kSaveOnlineParamsKey"
    
    /// 请求在线参数最大次数
    private let onlineMaxCout = 5
    
    /// 是否正在请求
    private var isRequestingParams: Bool = false
    /// 请求参数次数
    private var paramsRequestCount: Int = 0
    
    static let shared = TYOnlineParamsHelper()
    
    override init() {
        super.init()
        lock.name = "com.ttyy.onlineParams"
        onlineParamsPrivate = getOnlineParamsModel()
        if onlineParamsPrivate == nil {
            onlineParamsPrivate = TYOnlineParamsModel()
            onlineParamsPrivate?.setupDefaultValue()
        }
    }
    
    class func startService() {
        TYOnlineParamsHelper.shared.requestOnlineParams()
    }
    
}

private extension TYOnlineParamsHelper {
    func requestOnlineParams() {
        if isRequestingParams {
            return
        }
        isRequestingParams = true
        if paramsRequestCount >= 5 {
            return
        }
        
        YJSSessionManager.createRequest(.api, method: .get, path: "/freetxtkey", params: ["platform": "iOS_ttyy"]).responseJSON { isSuccess, result, error, _ in
            self.isRequestingParams = false
            self.paramsRequestCount += 1
            if !isSuccess {
                self.handleRequestOnlineParamsFaild()
                return
            }
            if let ok = result["ok"] as? Bool, ok, let data = result["data"] as? String {
                let decryptedContent = FBEncryptorAESUtils.getDecryptedContent(data)
                if let decryptedData = decryptedContent?.data(using: .utf8), let dataDic = try? JSONSerialization.jsonObject(with: decryptedData, options: .mutableLeaves) as? [String: Any] {
                    self.paramsRequestCount = self.onlineMaxCout
                    self.handleRequestOnlineParamsSuccess(dataDic)
                }
            } else {
                self.handleRequestOnlineParamsFaild()
            }
        }
    }
    
    func handleRequestOnlineParamsFaild() {
        if paramsRequestCount != onlineMaxCout  {
            // 重新请求在线参数
            requestOnlineParams()
        }
    }
    
    func handleRequestOnlineParamsSuccess(_ dict: [String: Any]) {
        lock.lock()
        onlineParamsPrivate = dict.kj.model(TYOnlineParamsModel.self)
        saveOnlieParamsModel(onlineParamsPrivate)
        lock.unlock()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TYNotificationOnlieParamsChaged), object: nil)
    }
}

// MARK: - 对数据库操作
private extension TYOnlineParamsHelper {
    
    func getOnlineParamsModel() -> TYOnlineParamsModel? {
        if let model = onlineParamsModel {
            return model
        }
        
        if let model = try? modelCache.entry(forKey: modelSaveKey).object {
            onlineParamsPrivate = model
            return model
        }
        
        return nil
    }
    
    func saveOnlieParamsModel(_ model: TYOnlineParamsModel?) {
        guard let onlineParams = model else { return }
        onlineParamsPrivate = onlineParams
        try? TYOnlineParamsHelper.shared.modelCache.setObject(onlineParams, forKey: modelSaveKey)
    }
}
