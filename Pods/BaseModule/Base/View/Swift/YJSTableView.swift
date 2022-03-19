//
//  YJSTableView.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 2/8/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import UIKit

open class YJSTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initParam()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init\(aDecoder) has not been implemented")
    }
    
    func initParam() {
        backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            estimatedSectionFooterHeight = 0;
            estimatedSectionHeaderHeight = 0;
            estimatedRowHeight = 0;
        }
    }
}
