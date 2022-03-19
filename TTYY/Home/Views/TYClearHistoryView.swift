//
//  TYClearHistoryView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/7.
//

import UIKit
import BaseModule

class TYClearHistoryView: UIView {
    var clearHistoryClosure: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYClearHistoryView {
    func createSubviews() {
        backgroundColor = Color_HexA(0x000000, alpha: 0.6)
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = Screen_IPadMultiply(10)
        bgView.layer.masksToBounds = true
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(309))
            make.height.equalTo(Screen_IPadMultiply(208))
            make.center.equalToSuperview()
        }
        
        let tipLb1 = UILabel()
        tipLb1.text = "提示"
        tipLb1.font = Font_Semibold_IPadMul(18)
        tipLb1.textColor = Color_Hex(0x262626)
        tipLb1.textAlignment = .center
        bgView.addSubview(tipLb1)
        tipLb1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_IPadMultiply(33))
        }
        
        let tipLb2 = UILabel()
        tipLb2.text = "确定清空搜索历史吗？"
        tipLb2.font = Font_Medium_IPadMul(14)
        tipLb2.textAlignment = .center
        bgView.addSubview(tipLb2)
        tipLb2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLb1.snp.bottom).offset(Screen_IPadMultiply(24))
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        cancelBtn.titleLabel?.font = Font_System_IPadMul(14)
        cancelBtn.layer.cornerRadius = Screen_IPadMultiply(8)
        cancelBtn.layer.masksToBounds = true
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        bgView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(108))
            make.height.equalTo(Screen_IPadMultiply(40))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-30))
            make.left.equalToSuperview().offset(Screen_IPadMultiply(40))
        }
        
        let clearBtn = UIButton()
        clearBtn.setTitle("清空", for: .normal)
        clearBtn.setTitleColor(Color_Hex(0xE11521), for: .normal)
        clearBtn.titleLabel?.font = Font_System_IPadMul(14)
        clearBtn.layer.borderWidth = 1
        clearBtn.layer.borderColor = Color_Hex(0xE11521).cgColor
        clearBtn.layer.cornerRadius = Screen_IPadMultiply(8)
        clearBtn.layer.masksToBounds = true
        clearBtn.addTarget(self, action: #selector(clearBtnClick), for: .touchUpInside)
        bgView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { make in
            make.width.height.bottom.equalTo(cancelBtn)
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-40))
        }
        
    }
    
    @objc func cancelBtnClick() {
        removeFromSuperview()
    }
    
    @objc func clearBtnClick() {
        TYCacheHelper.removeString(for: kSaveSearchKeyWordHistoryKey)
        clearHistoryClosure?()
        removeFromSuperview()
    }
}
