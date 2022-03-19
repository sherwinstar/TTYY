//
//  YJSUrlComposer.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/17.
//

import Foundation

public class YJSUrlComposer {
    public class func h5(path: String, params: [String: Any]? = nil) -> URL? {
        return url(.h5, path: path, params: params)
    }
    
    public class func api(path: String, params: [String: Any]? = nil) -> URL? {
        return url(.api, path: path, params: params)
    }
    
    public class func chapter(path: String, params: [String: Any]? = nil) -> URL? {
        return url(.chapter2, path: path, params: params)
    }
    
    public class func b(path: String, params: [String: Any]? = nil) -> URL? {
        return url(.b, path: path, params: params)
    }
    
    public class func statics(path: String, params: [String: Any]? = nil) -> URL? {
        return url(.statics, path: path, params: params)
    }
    
    public class func url(_ hostType: YJSRequestHostType, path: String, params: [String: Any]? = nil) -> URL? {
        let requestDescriptor = YJSReqDescriptor(hostType, method: .get, path: path, params: params)
        return url(requestDescriptor)
    }
    
    private class func url(_ requestDesc: YJSReqDescriptor) -> URL? {
        let urlStr = requestDesc.composeUrl()
        let url = URL(string: urlStr) ?? URL(string: urlStr.yjs_queryEncodedURLString() ?? "")
        guard var domain = url else {
            return nil
        }
        if let params = requestDesc.params as? [String: String] {
            domain = domain.appendingQueryParameters(params)
        }
        
        return domain
    }
}
