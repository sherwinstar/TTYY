//
//  Data+Extensions.swift
//  YouShaQi
//
//  Created by Beginner on 2020/6/5.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation

extension Data {
    /// 图片 Data 的 mimeType
    public func mimeType() -> String? {
        let bytes = withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 4), count: 1))
        }
        guard let c = bytes.first else {
            return nil
        }
        
        switch (c) {
        case 255:
            return "image/jpeg"
        case 137:
            return "image/png"
        case 71:
            return "image/gif"
        case 73, 77:
            return "image/tiff"
        default:
            return nil
        }
    }
}
