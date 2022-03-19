//
//  Character+Extensions.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 5/8/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
extension Character {
    /// Character 转成 unicode 值
    public func toInt() -> Int {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
}
