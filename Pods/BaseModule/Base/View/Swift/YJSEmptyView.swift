//
//  YJSEmptyView.swift
//  BaseModule
//
//  Created by Admin on 2020/8/7.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import RxSwift

//MARK: - 定义 EmptyView
public enum YJSEmptyDataType {
    case `default`
    case network
}

private class YJSEmptyViewModel {
    // 题目
    var titleImgName: String
    
    // 文字副标题
    var tipAttributeMsg: NSAttributedString?
    var tipMsg: String?
    var tipLabelFont: UIFont?
    var tipColor: UIColor?
    // 图片副标题
    var tipImgName: String?
    
    //文字子标题
    var tipSubAttributeMsg: NSAttributedString?
    var tipSubMsg: String?
    var tipSubLabelFont: UIFont?
    var tipSubColor: UIColor?
    
    // 按钮
    var btnTitle: String?
    var btnBgColor: UIColor?
    var btnTitleColor: UIColor?
    var btnBorderColor: UIColor?
    var btnBorderWidth: CGFloat = 0
    var btnFont: UIFont?
    
    init(titleImgName: String) {
        self.titleImgName = titleImgName
    }
    
    static func defaultNetworkModel() -> YJSEmptyViewModel {
        
        #if TARGET_ZSSQ
        // 追书
        let model = YJSEmptyViewModel(titleImgName: "zs_nodata_network")
        
        model.tipLabelFont = Font_System_IPadMul(15)
        model.tipMsg = "咦，怎么没网了..."
//        model.tipColor = Color_Hex(0xD8D8D8)
        model.tipColor = Color_Hex(0x879099)
        model.tipImgName = nil // 图片副标题
        
        model.tipSubColor = Color_Hex(0x879099)
        model.tipSubLabelFont = Font_Regular(14)
        
        model.btnTitle = nil
        model.btnBgColor = Color_ThemeWhite
        model.btnTitleColor = Color_ThemeRed
        model.btnBorderColor = Color_ThemeRed
        model.btnBorderWidth = 1
        model.btnFont = Font_System_IPadMul(15)
        return model
        #elseif TARGET_TTYY
        let model = YJSEmptyViewModel(titleImgName: "nodata_network")
        
        model.tipLabelFont = Font_System_IPadMul(14)
        model.tipMsg = "咦，怎么没有网了"
        model.tipColor = Color_Hex(0x999999)
        model.tipImgName = nil // 图片副标题
        
        model.tipSubColor = Color_Hex(0x879099)
        model.tipSubLabelFont = Font_Regular(14)
        
        model.btnTitle = "刷新"
        model.btnBgColor = Color_Hex(0xE11521)
        model.btnTitleColor = .white
        model.btnBorderColor = Color_Hex(0xE11521)
        model.btnBorderWidth = 1
        model.btnFont = Font_System_IPadMul(14)
        return model
        #else
        
        // 饭团
        let model = YJSEmptyViewModel(titleImgName: "nodata_network")
        
        model.tipLabelFont = nil
        model.tipMsg = nil
//        model.tipColor = Color_Hex(0xDADAE9)
        model.tipColor = Color_Hex(0x879099)
        model.tipImgName = "network_error_title" // 图片副标题
        
        model.tipSubColor = Color_Hex(0x879099)
        model.tipSubLabelFont = Font_Regular(14)
        
        model.btnTitle = "刷新"
        model.btnBgColor = Color_ThemeYellow
        model.btnTitleColor = Color_Hex(0x8F4D00)
        model.btnBorderColor = nil
        model.btnBorderWidth = 0
        model.btnFont = Font_Medium(18)
        return model
        #endif
    }
    
    static func defaultEmptyModel() -> YJSEmptyViewModel {
        #if TARGET_ZSSQ
        // 追书
        let model = YJSEmptyViewModel(titleImgName: "zs_nodata_default")
        
        model.tipLabelFont = Font_System_IPadMul(15)
        model.tipMsg = "这里什么都没有"
//        model.tipColor = Color_Hex(0xD8D8D8)
        model.tipColor = Color_Hex(0x879099)
        model.tipImgName = nil // 图片副标题
        model.tipSubLabelFont = Font_Regular(14)
        model.tipSubColor = Color_Hex(0x879099)
        
        model.btnTitle = nil
        model.btnBgColor = Color_ThemeWhite
        model.btnTitleColor = Color_ThemeRed
        model.btnBorderColor = Color_ThemeRed
        model.btnBorderWidth = 1
        model.btnFont = Font_System_IPadMul(15)
        return model
        #else
        
        // 饭团
        let model = YJSEmptyViewModel(titleImgName: "nodata_empty_new")
        
        model.tipLabelFont = Font_Medium(18) // 饭团的空白页有两种：题目+文字副标题/题目+按钮
        model.tipMsg = nil
//        model.tipColor = Color_Hex(0xDADAE9)
        model.tipColor = Color_Hex(0x879099)
        model.tipImgName = nil
        model.tipSubLabelFont = Font_Regular(14)
        model.tipSubColor = Color_Hex(0x879099)

        model.btnTitle = nil
        model.btnBgColor = Color_ThemeYellow
        model.btnTitleColor = .black
        model.btnBorderColor = nil
        model.btnBorderWidth = 0
        model.btnFont = Font_Medium(18)
        return model
        #endif
    }
}

public class YJSEmptyDataView: UIView {
    public var tipLabelClickClosure: (() -> ())?
    private var viewModel: YJSEmptyViewModel
    
    private var type: YJSEmptyDataType
    
    private var titleImgView: UIImageView? // 主要图片，相当于题目
    private var tipImgView: UIImageView? // 提示图片，相当于副标题，tipImgView 和 tipLabel 只会同时显示一个
    private var tipLabel: UILabel? // 提示label，相当于副标题，tipImgView 和 tipLabel 只会同时显示一个
    private var tipSubLabel: UILabel?
    private var actionButton: UIButton? // 按钮
    private var contentView: UIView? // 为了居中显示
    
    private var actionBlock: (() -> ())?
    
    public init(frame: CGRect, type: YJSEmptyDataType, tipMsg: String?, btnTitle: String?, actionBlock:(()->())?) {
        self.type = type
        let viewModel: YJSEmptyViewModel
        if type == .default {
            viewModel = YJSEmptyViewModel.defaultEmptyModel()
        } else {
            viewModel = YJSEmptyViewModel.defaultNetworkModel()
        }
        self.viewModel = viewModel
        super.init(frame: frame)
        if (tipMsg != nil) {
            self.viewModel.tipMsg = tipMsg
        }
        #if !TARGET_TTYY
        if (btnTitle != nil) {
            self.viewModel.btnTitle = btnTitle
        }
        #endif
        if actionBlock != nil {
            self.actionBlock = actionBlock
        }
        createView()
    }
    
    public init(frame: CGRect, type: YJSEmptyDataType, tipMsg: String?, tipSubMsg: String?, btnTitle: String?, actionBlock:(()->())?) {
        self.type = type
        let viewModel: YJSEmptyViewModel
        if type == .default {
            viewModel = YJSEmptyViewModel.defaultEmptyModel()
        } else {
            viewModel = YJSEmptyViewModel.defaultNetworkModel()
        }
        self.viewModel = viewModel
        super.init(frame: frame)
        if (tipMsg != nil) {
            self.viewModel.tipMsg = tipMsg
        }
        if (tipSubMsg != nil) {
            self.viewModel.tipSubMsg = tipSubMsg
        }
        #if !TARGET_TTYY
        if (btnTitle != nil) {
            self.viewModel.btnTitle = btnTitle
        }
        #endif
        if actionBlock != nil {
            self.actionBlock = actionBlock
        }
        createView()
    }
    
    public init(frame: CGRect, type: YJSEmptyDataType) {
        self.type = type
        let viewModel: YJSEmptyViewModel
        if type == .default {
            viewModel = YJSEmptyViewModel.defaultEmptyModel()
        } else {
            viewModel = YJSEmptyViewModel.defaultNetworkModel()
        }
        self.viewModel = viewModel
        super.init(frame: frame)
        createView()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == actionButton {
            return hit
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createView() {
        backgroundColor = .white
        let content = UIView()
        contentView = content
        content.backgroundColor = .clear
        addSubview(content)
        content.snp.makeConstraints({ (make) in
            make.center.equalTo(self)
        })
        
        // titleImgView 是必定会有的
        let title = UIImageView(image: UIImage(named: self.viewModel.titleImgName))
        self.titleImgView = title
        content.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.top.equalTo(content)
            make.centerX.equalTo(content)
            make.left.greaterThanOrEqualTo(content)
            make.right.lessThanOrEqualTo(content)
        }
        
        var centerView: UIView? = nil
        // 根据 tipMsg/tipImgName 决定是否展示
        if (self.viewModel.tipMsg != nil) {
            let tip = UILabel()
            self.tipLabel = tip
            content.addSubview(tip)
            tip.font = self.viewModel.tipLabelFont
            tip.textColor = self.viewModel.tipColor
            tip.textAlignment = .center
            tip.numberOfLines = 2
            tip.text = self.viewModel.tipMsg?.yjs_translateStr()
            centerView = tip
            //有大标题的时候才有小标题
            if (self.viewModel.tipSubMsg != nil) {
                let subTip = UILabel()
                self.tipSubLabel = subTip
                content.addSubview(subTip)
                subTip.font = self.viewModel.tipSubLabelFont
                subTip.textColor = self.viewModel.tipSubColor
                subTip.textAlignment = .center
                subTip.numberOfLines = 2
                subTip.text = self.viewModel.tipSubMsg?.yjs_translateStr()
                self.tipSubLabel?.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(tip.snp_bottom).offset(Screen_IPadMultiply(5))
                })
            }
        } else if let tipImgName = self.viewModel.tipImgName {
            let tip = UIImageView(image: UIImage(named: tipImgName))
            self.tipImgView = tip
            content.addSubview(tip)
            centerView = tip
        }
        
        centerView?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(content)
            make.top.equalTo(title.snp_bottom).offset(Screen_IPadMultiply(24))
            make.left.greaterThanOrEqualTo(content)
            make.right.lessThanOrEqualTo(content)
            if (self.viewModel.btnTitle == nil) {
                make.bottom.equalTo(content)
            }
        })
        // 根据 btnTitle 决定是否展示
        if (self.viewModel.btnTitle != nil) {
            let btn = UIButton(type: .custom)
            self.actionButton = btn
            content.addSubview(btn)
            #if TARGET_TTYY
            btn.layer.cornerRadius = Screen_IPadMultiply(8)
            #else
            btn.layer.cornerRadius = Screen_IPadMultiply(20)
            #endif
            btn.layer.borderColor = self.viewModel.btnTitleColor?.cgColor
            btn.layer.borderWidth = self.viewModel.btnBorderWidth
            btn.setTitleColor(self.viewModel.btnTitleColor, for: .normal)
            btn.backgroundColor = self.viewModel.btnBgColor
            btn.titleLabel?.font = self.viewModel.btnFont
            btn.setTitle(self.viewModel.btnTitle, for:.normal)
            btn.addTarget(self, action: #selector(handleActionBtn), for: .touchUpInside)
            #if TARGET_ZSSQ
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            #endif
        }
        self.actionButton?.snp.makeConstraints({ (make) in
            // 水平居中，左右边
            make.centerX.equalTo(content)
            make.left.greaterThanOrEqualTo(content)
            make.right.lessThanOrEqualTo(content)
            // 距离上一个视图的高度
            let lastView = centerView ?? title
            let hasCenterView = centerView != nil
            let topMargin = Screen_IPadMultiply(hasCenterView ? 16 : 40)
            make.top.equalTo(lastView.snp_bottom).offset(topMargin)
            // 距离底部的高度
            make.bottom.equalTo(content)
            // 固定高度
            make.height.equalTo(Screen_IPadMultiply(40))
            #if TARGET_FTZS
            make.width.equalTo(Screen_IPadMultiply(163))
            #elseif TARGET_TTYY
            make.width.equalTo(Screen_IPadMultiply(96))
            #endif
        })
    }
    
    @objc func handleActionBtn() {
        self.actionBlock?()
    }
    
    public func updateTipMsg(_ tipMsg: String?) {
        self.viewModel.tipMsg = tipMsg
        self.tipLabel?.text = tipMsg?.yjs_translateStr()
    }
    
    public func updateAttributeTipMsg(_ tipAttributeMsg: NSAttributedString?) {
        self.viewModel.tipAttributeMsg = tipAttributeMsg
        self.tipLabel?.attributedText = tipAttributeMsg
    }
    
    public func updateTipSubMsg(_ tipSubMsg: String?) {
        self.viewModel.tipSubMsg = tipSubMsg
        self.tipSubLabel?.text = tipSubMsg?.yjs_translateStr()
    }
    
    public func updateSubAttributeTipMsg(_ tipSubAttributeMsg: NSAttributedString?) {
        self.viewModel.tipSubAttributeMsg = tipSubAttributeMsg
        self.tipSubLabel?.attributedText = tipSubAttributeMsg
    }
}
