//
//  YJSActionSheet.swift
//  BaseModule
//
//  Created by Admin on 2020/9/4.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

//MARK: - 自定义 action sheet
public struct YJSActionSheet {
    /// 在主线程展示 自定义的 action sheet，没有用系统的 action sheet，取消与其他选项是连在一起的，
    public static func showCustomSheet(title: String?, btnsTtiles: [String], clickClosure: @escaping (Int?) -> ()) {
        doInMain {
            guard btnsTtiles.count > 0, let window = UIApplication.getWindow() else {
                return
            }
            //正在展示的sheet移除掉，并且不通知外界
            showingCustomSheet(in: window)?.removeFromSuperview()
            let sheet = createCustomSheet(title: title, btnsTtiles: btnsTtiles, clickClosure: clickClosure)
            sheet.tag = 200904
            window.addSubview(sheet)
            sheet.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            showSheet(sheet)
        }
    }
    
    /// 正在展示的 sheet
    private static func showingCustomSheet(in window: UIView) -> UIView? {
        window.subviews.first { (subview) -> Bool in
            subview.tag == 200904
        }
    }
    
    /// 创建自定义 sheet
    private static func createCustomSheet(title: String?, btnsTtiles: [String], clickClosure: @escaping (Int?) -> ()) -> UIView {
        let sheet = UIView()
        sheet.backgroundColor = .clear
        
        let bgBtn = UIButton(type: .custom)
        bgBtn.rx.tap.bind(onNext: { [weak sheet] in
            hideSheet(sheet)
            clickClosure(nil)
        }).disposed(by: sheet.disposeBag)
        sheet.addSubview(bgBtn)
        bgBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 高度计算
        let hasTitle = title != nil
        let rowHeight = Screen_IPadMultiply(64.0)
        let cancelHeight = Screen_IPadMultiply(50.0)
        let titleHeight: CGFloat = hasTitle ? Screen_IPadMultiply(73) : 0
        let allHeight = CGFloat(btnsTtiles.count) * rowHeight + cancelHeight + titleHeight
        
        // 毛玻璃效果
        let effect = UIBlurEffect(style: .extraLight)
        let blur = UIVisualEffectView(effect: effect)
        blur.isUserInteractionEnabled = true
        blur.layer.masksToBounds = true
        blur.layer.cornerRadius = Screen_IPadMultiply(8)
        blur.contentView.backgroundColor = sColor_RGBA(255, 255, 255, 0.7)
        sheet.addSubview(blur)
        blur.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(10))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-10))
            make.height.equalTo(allHeight)
            make.top.equalTo(sheet.snp_bottom) // 先放在最下面，之后还要做动画
        }

        // 选项按钮
        let actionBtns = btnsTtiles.reduce(into: []) { (btns, title) in
            let actionBtn = UIButton(type: .custom)
            actionBtn.titleLabel?.font = Font_System_IPadMul(17)
            actionBtn.setTitleColor(Color_Hex(0x616166), for: .normal)
            actionBtn.setTitle(title.yjs_translateStr(), for: .normal)
            let line = UIView()
            line.backgroundColor = Color_Hex(0xEBEBF0)
            line.isUserInteractionEnabled = false
            actionBtn.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
            blur.contentView.addSubview(actionBtn)
            actionBtn.snp.makeConstraints { (make) in
                make.height.equalTo(rowHeight)
                make.left.right.equalToSuperview()
                if let last = btns.last as? UIButton {
                    make.top.equalTo(last.snp_bottom)
                } else {
                    make.top.equalToSuperview().offset(titleHeight)
                }
            }
            actionBtn.tag = btns.count + 100
            actionBtn.rx.tap.bind(onNext: { [weak sheet] in
                hideSheet(sheet)
                clickClosure(actionBtn.tag - 100)
            }).disposed(by: sheet.disposeBag)
            btns.append(actionBtn)
        }
        guard let lastBtn = actionBtns.last as? UIButton else {
            // 不会出现这种情况的
            return sheet
        }
        
        // 取消按钮
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.backgroundColor = sColor_RGB(240, 240, 240)
        cancelBtn.titleLabel?.font = Font_System_IPadMul(17)
        cancelBtn.setTitle("取 消".yjs_translateStr(), for: .normal)
        cancelBtn.setTitleColor(Color_Hex(0xB7B7BD), for: .normal)
        cancelBtn.rx.tap.bind(onNext: { [weak sheet] in
            hideSheet(sheet)
            clickClosure(nil)
        }).disposed(by: sheet.disposeBag)
        blur.contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.height.equalTo(cancelHeight)
            make.left.right.equalToSuperview()
            make.top.equalTo(lastBtn.snp_bottom)
        }
        
        if hasTitle {
            let titleLabel = UILabel()
            titleLabel.font = Font_Bold_IPadMul(18)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .center
            blur.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.top.equalToSuperview()
                make.height.equalTo(titleHeight)
            }
        }
        return sheet
    }
    
    /// 展示 sheet 的动画
    static private func showSheet(_ sheet: UIView) {
        sheet.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            sheet.backgroundColor = Color_HexA(0, alpha: 0.4)
            if let contentView = sheet.subviews.last {
                contentView.snp.updateConstraints { (make) in
                    make.top.equalTo(sheet.snp_bottom).offset(-contentView.height)
                }
            }
            sheet.layoutIfNeeded()
        }
    }
    
    /// 隐藏 sheet 的动画
    static private func hideSheet(_ sheet: UIView?) {
        guard let view = sheet else {
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            view.backgroundColor = .clear
            if let contentView = view.subviews.last {
                contentView.snp.updateConstraints { (make) in
                    make.top.equalTo(view.snp_bottom)
                }
            }
            view.layoutIfNeeded()
        }) { (_) in
            view.removeFromSuperview()
        }
    }
}

//MARK: - 系统 action sheet
extension YJSActionSheet {
    /// 包转一层系统的 sheet，使它更好用
    public static func showSheet(title: String?, btnsTtiles: [String], in vc: UIViewController, clickClosure: @escaping (Int?) -> ()) {
        doInMain {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            var index: Int = 0
            for title in btnsTtiles {
                let i = index
                index = index + 1
                let action = UIAlertAction(title: title.yjs_translateStr(), style: .default, handler: { (_) in
                    clickClosure(i)
                })
                alert.addAction(action)
            }
            let cancel =  UIAlertAction(title: "取消".yjs_translateStr(), style: .cancel, handler: { (_) in
                clickClosure(nil)
            })
            alert.addAction(cancel)
            alert.popoverPresentationController?.sourceView = vc.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: Screen_Height - CGFloat(btnsTtiles.count * 60), width: Screen_Width, height: Screen_Height)
            alert.popoverPresentationController?.permittedArrowDirections = .unknown
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
