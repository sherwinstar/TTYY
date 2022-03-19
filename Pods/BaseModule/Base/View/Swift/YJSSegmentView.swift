//
//  YJSSegmentView.swift
//  YouShaQi
//
//  Created by Beginner on 2020/7/1.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import UIKit
import Foundation

public class YJSSegmentView: UIView {
    private var titles: [String] = []
    private var buttons: [UIButton] = []
    private var indicaterView = UIView()
    public var selectedChangedClosures: ((Int) -> Void)?
    public var selectedIndex: Int {
        set {
            if newValue == selectedIndex {
                return
            }
            guard let button = viewWithTag(newValue + 100) as? UIButton else {
                return
            }
            for btn in buttons {
                btn.isSelected = false
            }
            button.isSelected = true;
            UIView.animate(withDuration: 0.25) {
                self.indicaterView.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(button)
                    make.bottom.equalTo(self)
                    make.size.equalTo(CGSize(width: 42, height: 2))
                }
                self.layoutIfNeeded()
            }
            selectedChangedClosures?(newValue)
        }
        get {
            for button in buttons {
                if button.isSelected {
                    return button.tag - 100
                }
            }
            return 0
        }
    }
    public init(titles: [String]) {
        self.titles = titles
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createView() {
        let line = UIView()
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(Screen_IPadMultiply(15))
            make.right.equalTo(self).offset(Screen_IPadMultiply(-15))
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
        line.backgroundColor = Color_Hex(0xEBEBEB)
        
        let btnWidth = Screen_Width / CGFloat(titles.count)
        for index in 0 ..< titles.count {
            let btnSegment = UIButton()
            addSubview(btnSegment)
            btnSegment.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(self)
                make.left.equalTo(self).offset(btnWidth * CGFloat(index))
                make.width.equalTo(btnWidth)
            }
            btnSegment.setTitle(titles[index].yjs_translateStr(), for: .normal)
            btnSegment.titleLabel?.font = Font_Semibold(14)
            btnSegment.setTitleColor(Color_Hex(0x8A8A8F), for: .normal)
            btnSegment.setTitleColor(Color_Hex(0xEE4745), for: .selected)
            btnSegment.tag = 100 + index
            btnSegment.addTarget(self, action: #selector(onClickedItem(_:)), for: .touchUpInside)
            buttons.append(btnSegment)
        }
        
        if let firstSegment = buttons.first {
            indicaterView = UIView()
            addSubview(indicaterView)
            indicaterView.snp.makeConstraints { (make) in
                make.centerX.equalTo(firstSegment)
                make.bottom.equalTo(self)
                make.size.equalTo(CGSize(width: 42, height: 2))
            }
            indicaterView.layer.cornerRadius = 1
            indicaterView.layer.masksToBounds = true
            indicaterView.backgroundColor = Color_Hex(0xEE4745)
        }
    }
    
    @objc func onClickedItem(_ button: UIButton) {
        selectedIndex = button.tag - 100
    }
}
