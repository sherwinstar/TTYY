//
//  YJCompatible.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/24.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation

public struct YJ<Base> {
    init(_ base: Base) {}
}

public protocol YJCompatible {}
extension YJCompatible {
    public static var yj: YJ<Self>.Type {
        YJ<Self>.self
    }
    public var yj: YJ<Self> {
        YJ(self)
    }
}

extension String: YJCompatible {}

public struct Se<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol SeCompatible {}
extension SeCompatible {
    public static var se: Se<Self>.Type {
        get { Se<Self>.self }
        set {}
    }
    public var se: Se<Self> {
        get { Se(self) }
        set {}
    }
}

extension String: SeCompatible {}
