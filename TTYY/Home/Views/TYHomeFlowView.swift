//
//  TYHomeFlowView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/1.
//

import UIKit
import BaseModule

class TYHomeFlowView: UIView {
    
    var clickClosure: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFlowViewHeight() -> CGFloat {
        return Screen_IPadMultiply(20)
    }
}

private extension TYHomeFlowView {
    func createSubviews() {
//        let flowImgV = UIImageView(image: UIImage(named: "home_tip_flow"))
//        addSubview(flowImgV)
//        var flowW = Screen_Width - Screen_IPadMultiply(30)
//        if flowW > Screen_IPadMultiply(345) {
//            flowW = Screen_IPadMultiply(345)
//        }
//        let flowH = flowW * Screen_IPadMultiply(103) / Screen_IPadMultiply(345)
//        flowImgV.snp.makeConstraints { make in
//            make.width.equalTo(flowW)
//            make.height.equalTo(flowH)
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview()
//        }
        
//        let tip1 = createTipLabel(title: "复制商品名或链接")
//        addSubview(tip1)
//        let tipW = flowW / 3
//        tip1.snp.makeConstraints { make in
//            make.left.equalTo(flowImgV)
//            make.width.equalTo(tipW)
//            make.top.equalTo(flowImgV.snp.bottom)
//        }
        
//        let tip2 = createTipLabel(title: " 在有余领优惠")
//        addSubview(tip2)
//        tip2.snp.makeConstraints { make in
//            make.left.equalTo(tip1.snp.right)
//            make.width.equalTo(tipW)
//            make.top.equalTo(tip1)
//        }
//        let tip3 = createTipLabel(title: " 下单后返现")
//        addSubview(tip3)
//        tip3.snp.makeConstraints { make in
//            make.left.equalTo(tip2.snp.right)
//            make.width.equalTo(tipW)
//            make.top.equalTo(tip1)
//        }
        
        let wholeRuleBtn = UIButton()
        wholeRuleBtn.contentHorizontalAlignment = .right
        wholeRuleBtn.setTitle("查看完整教程", for: .normal)
        wholeRuleBtn.setTitleColor(Color_Hex(0x0081FC), for: .normal)
        wholeRuleBtn.titleLabel?.font = Font_System_IPadMul(14)
        addSubview(wholeRuleBtn)
        wholeRuleBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(Screen_IPadMultiply(20))
            make.width.equalTo(Screen_IPadMultiply(90))
        }
        wholeRuleBtn.addTarget(self, action: #selector(wholeRuleBtnClick), for: .touchUpInside)
        
        let arrowImgV = UIImageView(image: UIImage(named: "home_arrow_blue"))
        addSubview(arrowImgV)
        arrowImgV.snp.makeConstraints { make in
            make.centerY.equalTo(wholeRuleBtn)
            make.left.equalTo(wholeRuleBtn.snp.right).offset(Screen_IPadMultiply(3))
            make.right.equalToSuperview()
            make.width.height.equalTo(Screen_IPadMultiply(14))
        }
    }
    
//    func createTipLabel(title: String) -> UILabel {
//        let label = UILabel()
//        label.font = Font_System_IPadMul(14)
//        label.textAlignment = .center
//        label.textColor = Color_Hex(0x595959)
//        label.text = title
//        return label
//    }
    
    @objc func wholeRuleBtnClick() {
        clickClosure?()
    }
}
