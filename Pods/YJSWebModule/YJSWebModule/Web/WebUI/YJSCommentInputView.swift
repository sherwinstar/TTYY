
//
//  YJSCommentInputView.swift
//  YouShaQi
//
//  Created by 炼域至尊 on 2020/S/14.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import BaseModule

class YJSCommentInputView: UIView {
    
    private let bgView = UIView()
    private let inputTextView = UIPlaceHolderTextView()
    private let sendBtn = UIButton()
    private let actionBgView = UIView()
    
    var inputViewCloseClosure: ((String) -> ())?
    var sendClosure: ((String) -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        createInputSubview()
        registerNotifications()
    }
    
    func updateTextView(preTextStr: String) {
        inputTextView.becomeFirstResponder()
        inputTextView.text = preTextStr
    }
    
    func updateTextViewPlaceHolder(placeHolder: String) {
        inputTextView.becomeFirstResponder()
        inputTextView.placeholder = placeHolder.isBlank ? "随书而起，有感而发" : placeHolder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension YJSCommentInputView {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func createInputSubview() {
        self.frame = UIScreen.main.bounds
        addSubview(bgView)
        bgView.backgroundColor = Color_HexA(0x000000, alpha: 0.4)
//        bgView.frame = UIScreen.main.bounds
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(bgTapGes))
        bgView.addGestureRecognizer(tapGes)
        
        bgView.addSubview(actionBgView)
        actionBgView.backgroundColor = .white
        actionBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
//            make.width.equalTo(Screen_Width)
            make.height.equalTo(Screen_IPadMultiply(104))
            make.bottom.equalToSuperview().offset(0)
        }
        
        actionBgView.addSubview(sendBtn)
        sendBtn.setTitleColor(Color_Hex(0x879099), for: .normal)
        sendBtn.titleLabel?.font = Font_Medium(16)
        sendBtn.setTitle(YJLanguageHelper.translateStr("发送"), for: .normal)
        sendBtn.addTarget(self, action: #selector(sendBtnClick), for: .touchUpInside)
        let sendBtnW = Screen_IPadMultiply(60)
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(Screen_IPadMultiply(12))
            make.bottom.equalToSuperview().offset(-Screen_IPadMultiply(12))
            make.width.equalTo(sendBtnW)
        }
        
        actionBgView.addSubview(inputTextView)
        inputTextView.delegate = self
        inputTextView.becomeFirstResponder()
        inputTextView.backgroundColor = Color_Hex(0xF0F3F5)
        inputTextView.textColor = Color_Hex(0x262626)
        inputTextView.placeHolderTopPadding = 8
        inputTextView.placeHolderLeftPadding = 2
//        let inputTextViewW = Screen_Width - sendBtnW
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(15))
            make.right.equalTo(sendBtn.snp_left)
            make.top.bottom.equalTo(sendBtn)
//            make.width.equalTo(inputTextViewW)
        }
        inputTextView.font = Font_System(Screen_IPadMultiply(16))
        inputTextView.placeholder = YJLanguageHelper.translateStr("随书而起，有感而发")
        inputTextView.placeholderColor = Color_Hex(0x879099)
    }
    
    @objc func sendBtnClick() {
        let inputStr = inputTextView.text ?? ""
        if inputStr.isBlank {
            YJSToast.show(YJLanguageHelper.translateStr("发布评论不能为空"), topThanCenter: Screen_Height/3)
        } else {
            sendClosure?(inputTextView.text)
            removeFromSuperview()
        }
    }
    
    @objc func bgTapGes() {
        print("点击关闭")
        inputViewCloseClosure?(inputTextView.text)
        removeFromSuperview()
    }
    
    @objc func handleKeyBoardNotification(notification: Notification) {
        if notification.name == UIResponder.keyboardWillHideNotification {
            //键盘隐藏
            actionBgView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(Screen_IPadMultiply(104))
                make.bottom.equalToSuperview().offset(0)
            }
        } else {
            //键盘显示
            let keyBordFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyBordHeight = keyBordFrame.size.height
            actionBgView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(Screen_IPadMultiply(104))
                make.bottom.equalToSuperview().offset(-keyBordHeight)
            }
        }
    }
    
}

extension YJSCommentInputView: UITextViewDelegate {
    //将要进入编辑模式
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("UITextViewDelegate----1")
        return true
    }
    
    //已经进入编辑模式
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("UITextViewDelegate----2")
        
    }
    
    //将要结束/退去编辑模式
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("UITextViewDelegate----3")

        return true
    }
    
    //已经结束编辑模式
    func textViewDidEndEditing(_ textView: UITextView) {
        print("UITextViewDelegate----4")

    }
    
    //当textView的内容发生改变的时候调用
    func textViewDidChange(_ textView: UITextView) {
        print("UITextViewDelegate----5")
        let textViewStr = textView.text
        if textViewStr.isBlank {
            sendBtn.setTitleColor(Color_Hex(0x879099), for: .normal)
        } else {
            sendBtn.setTitleColor(Color_Hex(0x1667B8), for: .normal)
        }
    }
    
    ///选中textView 或者输入内容的时候调用[焦点发生改变]
    func textViewDidChangeSelection(_ textView: UITextView) {
         print("UITextViewDelegate----6")
    }
    
    //从键盘上将要输入到textView 的时候调用 [内容将要发生改变编辑]
    //rangge  光标的位置
    //text  将要输入的内容
    //返回YES 可以输入到textView中  NO不能
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("UITextViewDelegate----7")
        if range.location >= 500 {
            //可以控制e文字的长度
            return false
        }
//
//        if text == "\n" {
//            return false
//        }
//
        return true
    }
}
