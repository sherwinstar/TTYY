//
//  TYShopCategoryView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/9.
//

import UIKit
import BaseModule

class TYShopCategoryView: UIView {
    
    /// 分类点击
    var categoryClickClosure: ((Bool, TYBaseConfigModel?)->Void)?
    /// 分类更多点击
    var categoryMoreClosure: ((Bool, TYBaseConfigModel?)->Void)?
    
    /// 选中的分类
    var selectedModel: TYBaseConfigModel?
    
    private var moreBtn = UIButton()
    private var recommendBtn: UIButton?
    private var slideView = UIView()
    private var btnAllW: CGFloat = 0
    private var selectedBtn: UIButton?
    
    private var categorys: [TYBaseConfigModel]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCategorys(_ categorys: [TYBaseConfigModel]?) {
        self.categorys = categorys
        createCategorys()
    }
    
    func configCategory(_ category: TYBaseConfigModel) {
        selectedModel = category
        if let btn = viewWithTag(category.sort) as? UIButton {
            slideView.isHidden = false
            slideView.snp.remakeConstraints { make in
                make.width.equalTo(Screen_IPadMultiply(27))
                make.height.equalTo(Screen_IPadMultiply(4))
                make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-2))
                make.centerX.equalTo(btn)
            }
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
            btn.isSelected = true
            selectedBtn?.isSelected = false
            selectedBtn = btn
        } else {
            slideView.isHidden = true
            selectedBtn?.isSelected = false
            selectedBtn = nil
        }
    }
}

private extension TYShopCategoryView {
    func createSubviews() {
        backgroundColor = Color_Hex(0xF8F8F8)
        addSubview(moreBtn)
        moreBtn.setImage(UIImage(named: "shop_category_more"), for: .normal)
        moreBtn.setImage(UIImage(named: "shop_category_more"), for: .highlighted)
        moreBtn.addTarget(self, action: #selector(moreBtnClick), for: .touchUpInside)
        moreBtn.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(Screen_IPadMultiply(47))
        }
        let recBtn = getCategoryBtn(title: "推荐", tag: 1000)
        addSubview(recBtn)
        let w = getBtnW(title: "推荐")
        recBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.top.bottom.equalToSuperview()
            make.width.equalTo(w)
        }
        btnAllW = Screen_IPadMultiply(20) + w
        recommendBtn = recBtn
        recommendBtn?.isSelected = true
        selectedBtn = recBtn
        
        addSubview(slideView)
        slideView.backgroundColor = Color_Hex(0xE11521)
        slideView.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(27))
            make.height.equalTo(Screen_IPadMultiply(4))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-2))
            make.centerX.equalTo(recBtn)
        }
    }
    
    func getCategoryBtn(title: String, tag: Int) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(Color_Hex(0xE11521), for: .selected)
        btn.setTitleColor(Color_Hex(0x262626), for: .normal)
        btn.titleLabel?.font = Font_Medium_IPadMul(14)
        btn.addTarget(self, action: #selector(categoryBtnClick(_:)), for: .touchUpInside)
        btn.tag = tag
        return btn
    }
    
    func createCategorys() {
        guard var infos = categorys else { return }
        infos.sort(by: { m1, m2 in
            m1.sort < m2.sort
        })
        // 因为已经生成了recommendBtn，所以这里一定能有值
        var tempBtn = recommendBtn ?? UIButton()
        for model in infos {
            let btn = getCategoryBtn(title: model.value, tag: model.sort)
            let btnW = getBtnW(title: model.value)
            let targetW = btnAllW + btnW + Screen_IPadMultiply(25)
            if targetW > Screen_Width - Screen_IPadMultiply(47) {
                return
            }
            addSubview(btn)
            btn.snp.makeConstraints { make in
                make.bottom.top.equalToSuperview()
                make.left.equalTo(tempBtn.snp.right).offset(Screen_IPadMultiply(25))
                make.width.equalTo(btnW)
            }
            btnAllW = targetW
            tempBtn = btn
        }
        bringSubviewToFront(slideView)
    }
    
    @objc func moreBtnClick() {
        if selectedBtn == recommendBtn {
            categoryMoreClosure?(true, nil)
        } else {
            if let model = selectedModel {
                categoryMoreClosure?(false, model)
            } else {
                // 正常情况不会走到这里
                categoryMoreClosure?(false, nil)
            }
        }
    }
    
    @objc func categoryBtnClick(_ btn: UIButton) {
        slideView.isHidden = false
        slideView.snp.remakeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(27))
            make.height.equalTo(Screen_IPadMultiply(4))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-2))
            make.centerX.equalTo(btn)
        }
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
        selectedBtn?.isSelected = false
        btn.isSelected = true
        selectedBtn = btn
        if btn.tag == 1000 {
            selectedModel = nil
            categoryClickClosure?(true, nil)
        } else {
            let model = getBaseModel(btn.tag)
            selectedModel = model
            categoryClickClosure?(false, model)
        }
    }
    
    func getBtnW(title: String) -> CGFloat {
        let w = ((title + "  ") as NSString).boundingRect(with: CGSize(width: Screen_Width, height: CGFloat(MAXFLOAT)), options: .truncatesLastVisibleLine, attributes: [.font: Font_Medium_IPadMul(14)], context: nil).size.width
        return w
    }
    
    /// 根据sort获取model
    func getBaseModel(_ sort: Int) -> TYBaseConfigModel? {
        guard let infos = categorys else { return nil }
        for model in infos {
            if model.sort == sort {
                return model
            }
        }
        return nil
    }
}
