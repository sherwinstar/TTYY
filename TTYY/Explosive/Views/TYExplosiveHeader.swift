//
//  TYExplosiveHeader.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/2.
//

import UIKit
import BaseModule

class TYExplosiveHeader: UIView {

    /// 爆品点击
    var explosiveClickClosure: ((Int)->Void)?
    private let backgroundImageView = UIImageView()
    private let bgImageView = UIImageView()
    private let slideView = UIView()
    private var selectedButton : UIButton?
    private var buttons = [UIButton]()
    private var types :[TYShopRecommendType]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    convenience init(types: [TYShopRecommendType]?, frame: CGRect) {
//        self.init(frame: frame)
//        self.types = types
//        createSubviews()
//    }
    
    func loadData(_ types: [TYShopRecommendType]?) {
        self.types = types;
        loadButtons()
    }

}

private extension TYExplosiveHeader {
    func createSubviews() {
        let bgLayer = CAGradientLayer()
        bgLayer.colors = [UIColor(red: 0.24, green: 0.18, blue: 0.12, alpha: 1).cgColor, UIColor(red: 0.11, green: 0.07, blue: 0.05, alpha: 1).cgColor]
        bgLayer.locations = [0, 1]
        bgLayer.frame = self.bounds
        bgLayer.startPoint = CGPoint(x: 0.5, y: 0.35)
        bgLayer.endPoint = CGPoint(x: 1, y: 1)
        self.layer.addSublayer(bgLayer)
        
        bgImageView.image = UIImage(named: "explosive_header")
        addSubview(bgImageView)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.top.equalTo(Screen_NavItemY)
        }
        
        backgroundImageView.image = UIImage(named: "super_explosive")
        
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Screen_IPadMultiply(48))
            make.width.equalTo(Screen_IPadMultiply(127))
            make.height.equalTo(Screen_IPadMultiply(25))
            make.centerX.equalToSuperview()
        }
        slideView.isHidden = true
        slideView.backgroundColor = Color_Hex(0xF2DBB0)
        addSubview(slideView)
    }
    
    func loadButtons() {
        guard (types != nil) else {
            return
        }
        slideView.isHidden = false
        for index in 0..<types!.count {
            let button = UIButton()
            let type = types![index]
            button.setTitle(type.name, for: .normal)
            button.setTitleColor(UIColor(white: 1.0, alpha: 0.59), for: .normal)
            button.setTitleColor(Color_Hex(0xF2DBB0), for: .selected)
            button.titleLabel?.font = Font_Regular_IPadMul(14)
            button.addTarget(self, action: #selector(categoryBtnClick(_:)), for: .touchUpInside)
            button.tag = index + 1;
            buttons.append(button)
            self.addSubview(button)
            let width = button.intrinsicContentSize.width
            var offset = UIScreen.main.bounds.size.width / CGFloat(2 * types!.count) - width / 2
            offset += CGFloat(index) * UIScreen.main.bounds.size.width / CGFloat(types!.count)
            button.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-Screen_IPadMultiply(9))
                make.width.equalTo(width)
                make.height.equalTo(Screen_IPadMultiply(20))
                make.left.equalToSuperview().offset(offset)
            }
        }
        selectedButton = buttons.first
        selectedButton?.titleLabel?.font = Font_Medium_IPadMul(14)
        selectedButton?.isSelected = true
        slideView.snp.makeConstraints { make in
            make.width.equalTo(Screen_IPadMultiply(27))
            make.height.equalTo(Screen_IPadMultiply(4))
            make.bottom.equalToSuperview().offset(0)
            make.centerX.equalTo(selectedButton!)
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
        
        selectedButton?.isSelected = false
        selectedButton?.titleLabel?.font = Font_Regular_IPadMul(14)
        btn.isSelected = true
        selectedButton = btn
        selectedButton?.titleLabel?.font = Font_Medium_IPadMul(14)
        let type = types![btn.tag - 1]
        explosiveClickClosure?(type.id)
    }
}
