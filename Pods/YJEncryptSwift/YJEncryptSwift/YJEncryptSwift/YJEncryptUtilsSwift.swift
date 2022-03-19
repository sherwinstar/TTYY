//
//  YJEncryptUtilsSwift.swift
//  YJEncryptSwift
//
//  Created by YJPRO on 2020/12/8.
//

import UIKit
import AesGcm
import CommonCrypto

open class YJEncryptUtilsSwift: NSObject {
    
    /// 设置SDK是否打印日志
    /// - Parameter mode: YES打印，NO不打印
    @objc public class func configDebugMode(_ mode: Bool) {
        YJEncryptDataCenterSwift.share.debugMode = mode
    }
    
    /// 配置本SDK 需在app启动第一时间调用
    /// - Parameters:
    ///   - path: AppKey文件所在目录
    ///   - channelId: channelID
    @objc public class func configAppKeyDirectoryPath(_ path: String, channelId: String) {
        YJEncryptDataCenterSwift.share.channelID = channelId
        YJEncryptDataCenterSwift.share.AppKeyDirectoryPath = path
        
        decodeOriginStr()
        decodeChapterKey()
        decodeTokenKey()
    }
    
    /// 获取鉴权token
    @objc public class func getPermissionsToken() -> String {
        let date = Date.init(timeIntervalSinceNow: 0)
        let dateInt = Int(date.timeIntervalSince1970)
        let timeJson = convert2JSONWithDictionary(["time": dateInt])
        let toke = token(timeJson, aadStr: YJEncryptDataCenterSwift.share.channelID, keyStr: YJEncryptDataCenterSwift.share.tokenDecKey)
        return toke
    }
    
    
    /// 解密
    /// - Parameters:
    ///   - key: 原始key
    ///   - cipherText: 密文
    @objc public class func getDecryptedStr(key: String?, cipherText: String?) -> String {
        guard let encryptKey = key, let text = cipherText else { return "" }
        if isBlankString(encryptKey) || isBlankString(text) {
            return ""
        }
        
        let isPlainText = checkContentIsPlainText(text)
        if isPlainText {
            return text
        }
        
        let keyPlain = chapterKey(originStr: encryptKey)
        if isBlankString(keyPlain) {
            return ""
        }
        let ivLength = 16
        guard let keyData = Data(base64Encoded: keyPlain, options: .ignoreUnknownCharacters), let decodedCipherTextData = Data(base64Encoded: text, options: .ignoreUnknownCharacters) else {
            return ""
        }
        if decodedCipherTextData.count < ivLength {
            return ""
        }
        
        let clipedIvData = (decodedCipherTextData as NSData).subdata(with: NSRange(location: 0, length: ivLength))
        let clipedCipherTextData = (decodedCipherTextData as NSData).subdata(with: NSRange(location: ivLength, length: decodedCipherTextData.count - ivLength))
        return decryptData(clipedCipherTextData, key: keyData, iv: clipedIvData)
    }
    
    /// 获取明文key
    @objc public class func getKey(_ cipherKey: String) -> String {
        return chapterKey(originStr: cipherKey)
    }
    
    /// 判断是否是明文
    /// - Parameter cipherText: 内容
    @objc public class func checkContentIsPlainText(_ cipherText: String?) -> Bool {
        guard let text = cipherText else { return false }
        let len = text.count > 150 ? 150 : text.count
        let cutStr = (text as NSString).substring(to: len - 1)
        // 明文特征1:判断是否含有中文
        let isChinese = checkIsChinese(cutStr)
        if isChinese {
            return true
        }
        // 明文特征2:判断是否含有常用标点符号
        let symbolArr = ["。", ".", ",", "，", "?", "？", ":", "："]
        for s in symbolArr {
            if cutStr.contains(s) {
                return true
            }
        }
        // 不是明文
        return false
    }
}

// MARK: - 原数据处理
private extension YJEncryptUtilsSwift {
    /// 获取原始数据
    class func decodeOriginStr() {
        let array = Bundle.main.paths(forResourcesOfType: nil, inDirectory: YJEncryptDataCenterSwift.share.AppKeyDirectoryPath)
        if array.count == 0 {
            return
        }
        guard let filePath = array.first,
              let data = FileManager.default.contents(atPath: filePath),
              let enData = encodeData(data, key: "zhuishupartnerappxor"),
              let content = String.init(data: enData, encoding: .utf8) else { return }
        
        YJEncryptDataCenterSwift.share.originStr = content
        if YJEncryptDataCenterSwift.share.debugMode {
            print("YJEncryptUtils-AppKey明文=" + content)
        }
    }
    
    /// 获取用来解密chapter key  的key
    class func decodeChapterKey() {
        let originStr = YJEncryptDataCenterSwift.share.originStr
        if originStr.count != 272 {
            return
        }
        let firstStr = (originStr as NSString).substring(to: 136)
        YJEncryptDataCenterSwift.share.chapterEncKey = getKeyFrom136Str(firstStr)
        if YJEncryptDataCenterSwift.share.debugMode {
            print("YJEncryptUtils-解密chapterKey的key=" + YJEncryptDataCenterSwift.share.chapterEncKey)
        }
    }
    
    /// 获取 token key
    class func decodeTokenKey() {
        let originStr = YJEncryptDataCenterSwift.share.originStr
        if originStr.count != 272 {
            return
        }
        let secondStr = (originStr as NSString).substring(from: 136)
        YJEncryptDataCenterSwift.share.tokenDecKey = getKeyFrom136Str(secondStr)
        if YJEncryptDataCenterSwift.share.debugMode {
            print("YJEncryptUtils-tokenKey=" + YJEncryptDataCenterSwift.share.tokenDecKey)
        }
    }
    
    /// 异或
    class func encodeData(_ sourceData: Data, key: String) -> Data? {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }

        //取关键字的Byte数组, keyBytes一直指向头部
        let keyBytes = [UInt8](keyData)
        // 取需要加密的数据的Byte数组
        var sourceDataPoint = [UInt8](sourceData)
        for i in 0..<sourceData.count {
            let index = i % keyData.count
            //然后按位进行异或运算
            sourceDataPoint[i] = sourceDataPoint[i] ^ keyBytes[index]
        }
        return Data(sourceDataPoint)
    }
    
    /// 从136位字符串中获取key  （通用方法）
    class func getKeyFrom136Str(_ originStr: String) -> String {
        if originStr.count != 136 {
            return ""
        }
        let firstIndex = Int((originStr as NSString).substring(to: 2)) ?? 0
        let secondIndex = Int((originStr as NSString).substring(from: 134)) ?? 0
        let firstKey = (originStr as NSString).substring(with: NSRange(location: 2 + firstIndex, length: 16))
        let secondKey = (originStr as NSString).substring(with: NSRange(location: 2 + secondIndex, length: 16))
        return firstKey + secondKey
    }
}

// MARK: - 加解密相关
private extension YJEncryptUtilsSwift {
    class func token(_ text: String, aadStr: String, keyStr: String) -> String {
        if YJEncryptDataCenterSwift.share.debugMode {
            print("YJEncryptUtils-TimeJson=" + text)
            print("YJEncryptUtils-ChannelID=" + aadStr)
        }
        let ivStr = getRandomString(num: 12)
        guard let ivData = ivStr.data(using: .utf8), let keyData = keyStr.data(using: .utf8), let aadData = aadStr.data(using: .utf8), let textData = text.data(using: .utf8) else {
            return ""
        }
        let hexIV = hexString(databytes: [UInt8](ivData), length: ivData.count)
        guard let cipheredData = try? IAGAesGcm.cipheredData(byAuthenticatedEncryptingPlainData: textData, withAdditionalAuthenticatedData: aadData, authenticationTagLength: IAGAuthenticationTagLength.length128, initializationVector: ivData, key: keyData) else {
            return ""
        }
        
        let dataBuffer = cipheredData.cipheredBuffer
        let dataLength = cipheredData.cipheredBufferLength
        let hexStr = hexString(dataPointer: dataBuffer, length: Int(dataLength))
        
        let tagBuffer = cipheredData.authenticationTag
        let tagLength = cipheredData.authenticationTagLength
        let tagStr = hexString(dataPointer: tagBuffer, length: Int(tagLength.rawValue))
        let result = aadStr + ":" + hexIV + hexStr + tagStr
        if YJEncryptDataCenterSwift.share.debugMode {
            print("YJEncryptUtils-aadStr=" + aadStr)
            print("YJEncryptUtils-hexIV=" + hexIV)
            print("YJEncryptUtils-hexStr=" + hexStr)
            print("YJEncryptUtils-tagStr=" + tagStr)
        }
        return result
    }
    
    class func chapterKey(originStr: String) -> String {
        return chapterKey(originStr: originStr, ivStr: YJEncryptDataCenterSwift.share.channelID, keyStr: YJEncryptDataCenterSwift.share.chapterEncKey)
    }
    
    class func chapterKey(originStr: String, ivStr: String, keyStr: String) -> String {
        if isBlankString(originStr) {
            return ""
        }
        guard let data = Data.init(base64Encoded: originStr, options: .ignoreUnknownCharacters) else {
            return ""
        }
        if data.count < 29 {
            return ""
        }
        
        let ivData = (data as NSData).subdata(with: NSRange(location: 0, length: 12))
        let tagData = (data as NSData).subdata(with: NSRange(location: data.count - 16, length: 16))
        let contentData = (data as NSData).subdata(with: NSRange(location: 12, length: data.count - 12 - 16))
        
        let aadData = ivStr.data(using: .utf8) ?? Data()
        let keyData = keyStr.data(using: .utf8) ?? Data()
        
        if let resultData = IAGCipheredData(cipheredData: contentData, authenticationTag: tagData),
           let plainData = try? IAGAesGcm.plainData(byAuthenticatedDecryptingCipheredData: resultData, withAdditionalAuthenticatedData: aadData, initializationVector: ivData, key: keyData) {
            let result = String(data: plainData, encoding: .utf8) ?? ""
            return result
        }
        return ""
    }
    
    class func decryptData(_ data: Data, key: Data, iv: Data) -> String {
        
        let keyPointer = (key as NSData).bytes

        let cv = NSData(data: iv).subdata(with: NSRange(location: 0, length: kCCBlockSizeAES128))
        let cIv = (cv as NSData).bytes

        // setup output buffer
        let bufferSize = data.count + kCCBlockSizeAES128
        let crypt = malloc(bufferSize)
        guard let cryptPointer = crypt else { return "" }
        // 加密或则解密后的数据长度
        var cryptBytesLength:size_t = 0

        let cryptStatus = CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES128), CCOptions(kCCOptionPKCS7Padding), keyPointer, key.count, cIv, (data as NSData).bytes, data.count, cryptPointer, bufferSize, &cryptBytesLength)

        var result: Data?
        if cryptStatus == kCCSuccess {
            result = NSData(bytesNoCopy: cryptPointer, length: cryptBytesLength) as Data
        }
        guard let decryptedData = result else {
            return ""
        }
        let decryptedStr = (NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue) ?? "") as String
        return decryptedStr
    }
}

private extension YJEncryptUtilsSwift {
    /// dic 转 json
    class func convert2JSONWithDictionary(_ dic: [String: Int]) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0)) else {
            return ""
        }
        let jsonString = String.init(data: jsonData, encoding: .utf8) ?? ""
        return jsonString
    }
    
    /// 获取随机字符串
    /// - Parameter num: 字符串长度
    class func getRandomString(num: Int) -> String {
        var string = ""
        for _ in 0..<num {
            let number = arc4random() % 36
            if number < 10 {
                let figure = arc4random() % 10
                string = string.appending("\(figure)")
            } else {
                let figure = (arc4random() % 26) + 97
                let character = Character(UnicodeScalar(figure) ?? UnicodeScalar(0))
                string = string.appending(String(character))
            }
        }
        return string
    }
    
    class func hexString(databytes: [UInt8], length: Int) -> String {
        var hexString = ""
        for i in 0..<length {
            hexString = hexString.appendingFormat("%02x", databytes[i])
        }
        return hexString
    }
    
    class func hexString(dataPointer: UnsafeRawPointer, length: Int) -> String {
        var hexString = ""
        for i in 0..<length {
            hexString = hexString.appendingFormat("%02x", dataPointer.load(fromByteOffset: i, as: UInt8.self))
        }
        
        return hexString
    }
    
    
    /// 判断String是否为空
    class func isBlankString(_ str: String) -> Bool {
        if str.isEmpty {
            return true
        }
        
        if str.isKind(of: NSNull.self) {
            return true
        }
        
        if str == "(null)" {
            return true
        }
        
        if str == "null" {
            return true
        }
        
        let string = str.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if string.isEmpty {
            return true
        }
        return false
    }
    
    /// 检测字符串中是否含有中文，备注：中文代码范围0x4E00~0x9FA5
    class func checkIsChinese(_ string: String) -> Bool {
        for i in 0..<string.count {
            let ch = (string as NSString).character(at: i)
            if 0x4E00 <= ch && ch <= 0x9FA5 {
                return true
            }
        }
        return false
    }
}
