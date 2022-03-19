//
//  TYUrlString.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/10/28.
//

import Foundation

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
}
