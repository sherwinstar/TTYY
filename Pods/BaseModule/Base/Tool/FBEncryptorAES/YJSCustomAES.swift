//
//  YJSCustomAES.swift
//  BaseModule
//
//  Created by Admin on 2020/9/4.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

/*
 AES 加密需要 iv 和 key
 */
@objc public class YJSCustomAES: NSObject {
    /// 基础的AES解密方法，key 和 iv 是固定的
    public static func AESDecrypt(originStr: String) -> String {
        guard !originStr.isEmpty,
            let keyData = "+BNC7v+HXyt7bJlp".data(using: .utf8),
            let ivData = "581ec9051f4cb2e6".data(using: .utf8),
            let originData = Data(base64Encoded: originStr) else {
            return ""
        }
        let result = FBEncryptorAES.decryptData(originData, key: keyData, iv: ivData)
            .flatMap {
                String(data: $0, encoding: .utf8)
            }
        return result ?? ""
    }
    
    /// 基础的AES加密方法，key 和 iv 是固定的
    @objc public static func AESEncrypt(originStr: String) -> String {
        guard !originStr.isEmpty,
            let keyData = Data(base64Encoded: "dqeM9RaURqJ77b702s5UQg=="),
            let ivData = Data(base64Encoded: "6WwS5EeCG1LROJ0cTlWNgw=="),
            let originData = originStr.data(using: .utf8) else {
            return ""
        }
        let result = FBEncryptorAES.encryptData(originData, key: keyData, iv: ivData)
            .flatMap {
                $0.base64EncodedString()
            }
        return result ?? ""
    }
    
    /// 配合 idfa 的 AES加密方法，key 和 iv 是固定的
    public static func AESEncryptMergeIdfa(originStr: String) -> String {
        guard !originStr.isEmpty,
            let keyData = "+BNC7v+HXyt7bJlp".data(using: .utf8),
            let ivData = "581ec9051f4cb2e6".data(using: .utf8),
            let originData = Data(base64Encoded: originStr),
            let idfaData = YJIdfaHelper.uniquelIdfa()?.data(using: .utf8) else {
            return ""
        }
        let result: String? = FBEncryptorAES.encryptData(originData, key: keyData, iv: ivData)
            .map { (data) -> Data in
                var left: Data = data
                return xor(left: &left, right: idfaData)
            }.flatMap {
                $0.base64EncodedString()
            }
        return result ?? ""
    }
    
    // 加密后的字符串第一位与deviceId第一位异或
    private static func xor(left: inout Data, right: Data) -> Data {
        let leftBytes = left.withUnsafeMutableBytes { $0 }
        let rightBytes = right.withUnsafeBytes { $0 }
        let replacedByte = leftBytes[0] ^ rightBytes[0]
        leftBytes[0] = replacedByte
        let result = Data(leftBytes)
        return left
    }
}

//MARK: - 利用AES自定义的加密方法
extension YJSCustomAES {
    
    /// 解密方式1: iv 是：originStr 二进制的前16位
    public static func customAESDecrypt(key: String, originStr: String) -> String {
        guard !key.isEmpty, !originStr.isEmpty else {
            return ""
        }
        let ivLength = 16
        // 把 key/originStr 都转成 data
        guard let keyData = Data(base64Encoded: key, options: []),
            let contentData = Data(base64Encoded: originStr, options: []),
            contentData.count >= ivLength else {
                return ""
        }
        // 取 originStr data 的前16位
        let leftContentIvData = contentData[0..<ivLength]
        let rightContentIvData = contentData[ivLength...]
        let decryptedData = FBEncryptorAES.decryptData(rightContentIvData, key: keyData, iv: leftContentIvData)
        let decryptedStr = decryptedData.flatMap {
            String(data: $0, encoding: .utf8)
        }
        return decryptedStr ?? ""
    }
    
    
    /// 解密方式2: 重复解密两次
    ///
    ///     第一次：key: key1, originStr: originStr, iv: originStr 二进制的前16位,
    ///     第二次：key: key2, 以上一次结果为 originStr, iv: originStr 二进制的前16位,
    public static func customAESDecrypt2Times(key1: String, key2: String, originStr: String) -> String {
        guard let firstDecryptedStr = customAESDecrypt2TimesPart(key: key1, originStr: originStr),
            let result = customAESDecrypt2TimesPart(key: key2, originStr: firstDecryptedStr) else {
            return ""
        }
        return result
    }
    
    private static func customAESDecrypt2TimesPart(key: String, originStr: String) -> String? {
        let ivLength = 16

        guard !key.isEmpty,
            !originStr.isEmpty,
            let keyData = Data(base64Encoded: key),
            let originData = Data(base64Encoded: originStr),
            originData.count > ivLength else {
            return nil // 转 data 判空
        }
        
        let leftOriginData = originData[..<ivLength]
        let rightOriginData = originData[ivLength...]
        let decryptedStr = FBEncryptorAES.decryptData(rightOriginData, key: keyData, iv: leftOriginData)
            .flatMap {
            String(data: $0, encoding: .utf8)
            }
        guard let result = decryptedStr, !result.isEmpty else {
            return nil
        }
        return result
    }
    
}
