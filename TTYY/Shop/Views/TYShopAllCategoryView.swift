//
//  TYShopAllCategoryView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/9.
//

import UIKit
import BaseModule

class TYShopAllCategoryView: UIView {
    var categoryClickClosure: ((TYBaseConfigModel)->Void)?
    
    /// 整体的容器
    private var contentView = UIView()
    /// 分类的容器
    private var categorysView = UIView()
    /// 分类数据
    private var categorys: [TYBaseConfigModel]?
    /// 最后一个分类
    private var lastCategory: TYCategoryView?
    /// 选中的分类
    private var selectedCategory: TYCategoryView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置数据
    func updateAllCategory(_ categorys: [TYBaseConfigModel]?) {
        self.categorys = categorys
        createCategorysView()
        doAfterInMain(seconds: 0.5) { [weak self] in
            self?.contentView.addCorner(cornerRadii: CornerRadii(topLeft: 0, topRight: 0, bottomLeft: Screen_IPadMultiply(10), bottomRight: Screen_IPadMultiply(10)))
            let contentH = self?.contentView.swift_height ?? Screen_Height
            self?.contentView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(-contentH)
            }
        }
        if let category = viewWithTag(1000) as? TYCategoryView {
            selectedCategory = category
            selectedCategory?.selectedView()
        }
    }
    
    func show(selectedInfo: TYBaseConfigModel) {
        contentView.snp.updateConstraints { make in
            make.top.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            self.isHidden = false
            self.layoutIfNeeded()
        }
        if let category = viewWithTag(selectedInfo.sort) as? TYCategoryView, category != selectedCategory {
            category.selectedView()
            selectedCategory?.resetView()
            selectedCategory = category
        }
    }
    
    @objc func hide() {
        let contentH = contentView.swift_height
        contentView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(-contentH)
        }
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden = true
        }

    }
}

private extension TYShopAllCategoryView {
    func createSubview() {
        backgroundColor = Color_HexA(0x000000, alpha: 0.6)
        layer.masksToBounds = true
        
        addSubview(contentView)
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        contentView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalToSuperview().offset(-Screen_Height)
        }
        
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x272727)
        tipLb.text = "选择分类"
        tipLb.font = Font_Medium_IPadMul(16)
        contentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(18))
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
        }
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "category_close"), for: .normal)
        contentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(26))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-12))
            make.top.equalToSuperview().offset(Screen_IPadMultiply(13))
        }
        closeBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        
        contentView.addSubview(categorysView)
        categorysView.backgroundColor = Color_Hex(0xF8F8F8)
        categorysView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(16))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-21))
        }
    }
    
    func createCategorysView() {
        guard var infos = categorys else { return }
        infos.sort(by: { m1, m2 in
            m1.sort < m2.sort
        })
        let recommendModel = TYBaseConfigModel(name: "recommend", value: "推荐", key: "1000", sort: 1000)
        infos.insert(recommendModel, at: 0)
        
        let btnW = (Screen_Width - Screen_IPadMultiply(69)) * 0.25
        let btnH = Screen_IPadMultiply(36)
        let hMargin = Screen_IPadMultiply(13)
        let vMargin = Screen_IPadMultiply(12)
        for e in infos.enumerated() {
            let category = TYCategoryView()
            category.updateView(infoModel: e.element)
            category.tag = e.element.sort
            // 行
            let rowNum = e.offset / 4
            // 列
            let colNum = e.offset % 4
            let x = Screen_IPadMultiply(15) + CGFloat(colNum) * (btnW + hMargin)
            let y = CGFloat(rowNum) * (btnH + vMargin)
            categorysView.addSubview(category)
            category.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.width.equalTo(btnW)
                make.height.equalTo(btnH)
            }
            if e.offset == infos.count - 1 {
                // 最后一个
                lastCategory = category
                category.snp.makeConstraints { make in
                    make.bottom.equalToSuperview()
                }
            }
            
            category.clickClosure = { [weak self] info in
                self?.handleCategoryClick(info)
            }
        }
    }
}

private extension TYShopAllCategoryView {
    func handleCategoryClick(_ info: TYBaseConfigModel?) {
        guard let model = info, let selView = selectedCategory else {
            hide()
            return
        }
        if model.sort == selView.tag {
            hide()
        } else {
            selectedCategory?.resetView()
            categoryClickClosure?(model)
            if let category = viewWithTag(model.sort) as? TYCategoryView {
                selectedCategory = category
            }
            hide()
        }
    }
}


class TYCategoryView: UIView {
    var clickClosure: ((TYBaseConfigModel?)->Void)?
    
    private var categoryLb = UILabel()
    private var infoModel: TYBaseConfigModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(infoModel: TYBaseConfigModel?) {
        self.infoModel = infoModel
        categoryLb.text = infoModel?.value
    }
    
    func resetView() {
        layer.borderWidth = 0
        categoryLb.backgroundColor = Color_Hex(0xEFEFEF)
        categoryLb.textColor = Color_Hex(0x595959)
    }
    
    func selectedView() {
        layer.borderWidth = 1
        layer.borderColor = Color_Hex(0xE11521).cgColor
        categoryLb.backgroundColor = Color_Hex(0xF8F8F8)
        categoryLb.textColor = Color_Hex(0xE11521)
    }
}

private extension TYCategoryView {
    func createSubviews() {
        layer.cornerRadius = Screen_IPadMultiply(6)
        layer.masksToBounds = true
        
        addSubview(categoryLb)
        categoryLb.font = Font_System_IPadMul(14)
        categoryLb.textAlignment = .center
        categoryLb.backgroundColor = Color_Hex(0xEFEFEF)
        categoryLb.textColor = Color_Hex(0x595959)
        categoryLb.numberOfLines = 2
        categoryLb.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @objc func tapAction() {
        selectedView()
        clickClosure?(infoModel)
    }
}
