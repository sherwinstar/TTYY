//
//  TYShopCategoryTool.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/16.
//

import UIKit
import BaseModule



class TYShopCategoryTool: UIView {
    /// 筛选
    var filterClosure: ((String, String)->Void)?
    
    /// 综合
    private var allBtn = UIButton()
    /// 销售
    private var saleBtn = UIButton()
    /// 价格
    private var priceBtn = UIButton()
    /// 价格指示图标
    private var priceIcon = UIImageView()
    /// 佣金比例
    private var moneyBtn = UIButton()
    /// 佣金比例图标
    private var moneyIcon = UIImageView()
    /// 选中的按钮
    private var selectedBtn = UIButton()
    
    /// 价格的顺序： -1： 没有点击， 1：升序， 2：降序
    private var priceOrder = -1
    /// 佣金比例的顺序： -1： 没有点击， 1：升序， 2：降序
    private var moneyOrder = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetState() {
        moneyOrder = -1
        priceOrder = -1
        priceIcon.isHidden = true
        moneyIcon.isHidden = true
        selectedBtn.isSelected = false
        allBtn.isSelected = true
        selectedBtn = allBtn
    }
}

private extension TYShopCategoryTool {
    func createSubviews() {
        backgroundColor = Color_Hex(0xF8F8F8)
        
        let line = UIView()
        line.backgroundColor = Color_Hex(0xEDEDED)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        addSubview(allBtn)
        refreshBtn(allBtn, title: "综合")
        allBtn.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(65))
        }
        addSubview(saleBtn)
        refreshBtn(saleBtn, title: "销售")
        saleBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(65))
            make.left.equalTo(allBtn.snp.right)
        }
        
        addSubview(priceBtn)
        refreshBtn(priceBtn, title: "价格")
        priceBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(65))
            make.left.equalTo(saleBtn.snp.right)
        }
        
        priceBtn.addSubview(priceIcon)
        priceIcon.image = UIImage(named: "shop_price_asc")
        priceIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(priceBtn.snp.left).offset(Screen_IPadMultiply(45))
            make.width.height.equalTo(Screen_IPadMultiply(17))
        }
        
        priceIcon.isHidden = true
        
        addSubview(moneyBtn)
        refreshBtn(moneyBtn, title: "佣金比例")
        moneyBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(90))
            make.left.equalTo(priceBtn.snp.right)
        }
        
        moneyBtn.addSubview(moneyIcon)
        moneyIcon.image = UIImage(named: "shop_price_desc")
        moneyIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Screen_IPadMultiply(70))
            make.width.height.equalTo(Screen_IPadMultiply(17))
        }
        
        moneyIcon.isHidden = true
        
        selectedBtn = allBtn
        allBtn.isSelected = true
    }
    
    func refreshBtn(_ btn: UIButton, title: String) {
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(Color_Hex(0x999999), for: .normal)
        btn.titleLabel?.font = Font_System_IPadMul(12)
        btn.setTitleColor(Color_Hex(0xE11521), for: .selected)
        btn.setTitleColor(Color_Hex(0xE11521), for: .highlighted)
        btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
    }
    
    @objc func btnClick(_ btn: UIButton) {
        if btn == selectedBtn {
            // 如果点击的按钮和选中的相等，并且是综合、销售按钮，直接返回，什么操作都不执行
            if btn == allBtn || btn == saleBtn {
                return
            }
            if btn == priceBtn {
                if priceOrder == 1 {
                    priceIcon.image = UIImage(named: "shop_price_desc")
                    priceOrder = 2
                    filterClosure?("price", "desc")
                } else if priceOrder == 2 {
                    priceIcon.image = UIImage(named: "shop_price_asc")
                    priceOrder = 1
                    filterClosure?("price", "asc")
                }
            } else if btn == moneyBtn {
                if moneyOrder == 1 {
                    moneyIcon.image = UIImage(named: "shop_price_desc")
                    moneyOrder = 2
                    filterClosure?("commissionShare", "desc")
                } else if moneyOrder == 2 {
                    moneyIcon.image = UIImage(named: "shop_price_asc")
                    moneyOrder = 1
                    filterClosure?("commissionShare", "asc")
                }
            }
            return
        }
        
        if btn == allBtn {
            btn.isSelected = true
            selectedBtn.isSelected = false
            priceIcon.isHidden = true
            moneyIcon.isHidden = true
            selectedBtn = btn
            priceOrder = -1
            moneyOrder = -1
            filterClosure?("goodComments", "desc")
        } else if btn == saleBtn {
            btn.isSelected = true
            selectedBtn.isSelected = false
            priceIcon.isHidden = true
            moneyIcon.isHidden = true
            selectedBtn = btn
            priceOrder = -1
            moneyOrder = -1
            filterClosure?("inOrderCount30DaysSku", "desc")
        } else if btn == priceBtn {
            btn.isSelected = true
            selectedBtn.isSelected = false
            priceIcon.isHidden = false
            moneyIcon.isHidden = true
            moneyOrder = -1
            selectedBtn = btn
            if priceOrder == -1 {
                priceIcon.image = UIImage(named: "shop_price_asc")
                priceOrder = 1
                filterClosure?("price", "asc")
            } else if priceOrder == 1 {
                priceIcon.image = UIImage(named: "shop_price_desc")
                priceOrder = 2
                filterClosure?("price", "desc")
            } else if priceOrder == 2 {
                priceIcon.image = UIImage(named: "shop_price_asc")
                priceOrder = 1
                filterClosure?("price", "asc")
            }
        } else if btn == moneyBtn {
            btn.isSelected = true
            selectedBtn.isSelected = false
            priceIcon.isHidden = true
            moneyIcon.isHidden = false
            priceOrder = -1
            selectedBtn = btn
            if moneyOrder == -1 {
                moneyIcon.image = UIImage(named: "shop_price_desc")
                moneyOrder = 2
                filterClosure?("commissionShare", "desc")
            } else if moneyOrder == 1 {
                moneyIcon.image = UIImage(named: "shop_price_desc")
                moneyOrder = 2
                filterClosure?("commissionShare", "desc")
            } else if moneyOrder == 2 {
                moneyIcon.image = UIImage(named: "shop_price_asc")
                moneyOrder = 1
                filterClosure?("commissionShare", "asc")
            }
        }
    }
}
