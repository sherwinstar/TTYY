//
//  TYShareView.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/22.
//

import UIKit
import BaseModule
import YJShareSDK

class TYShareView: UIView {
    
    var dismissClosure: (()->Void)?
    
    /// 分享按钮点击（Bool: true表示微信或者朋友圈第三方分享，false表示保存图片）
    var shareClosure: ((Bool,SSDKShareType)->Void)?
    
    init(dismissClosure:(()->Void)?) {
        self.dismissClosure = dismissClosure
        super.init(frame: CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(193 + Screen_SafeBottomHeight)))
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYShareView {
    func createSubviews() {
        let bgView = UIView()
        bgView.backgroundColor = .white
        addSubview(bgView)
        bgView.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_IPadMultiply(193 + Screen_SafeBottomHeight))
        bgView.roundCorners([.topLeft, .topRight], radius: Screen_IPadMultiply(16))
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tipLb = UILabel()
        tipLb.text = "分享至".yjs_translateStr()
        tipLb.textColor = Color_Hex(0x262626)
        tipLb.textAlignment = .center
        tipLb.font = Font_Medium_IPadMul(18)
        bgView.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(20))
            make.centerX.equalToSuperview()
        }
        
        // 朋友圈
        let friendBtn = TYShareButton()
        friendBtn.setTitle("朋友圈".yjs_translateStr(), for: .normal)
        friendBtn.setImage(UIImage(named: "share_wechat_friend_icon"), for: .normal)
        friendBtn.setTitleColor(Color_Hex(0x262626), for: .normal)
        friendBtn.titleLabel?.font = Font_System_IPadMul(15)
        friendBtn.titleLabel?.textAlignment = .center
        friendBtn.tag = 2
        friendBtn.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
        bgView.addSubview(friendBtn)
        friendBtn.snp.makeConstraints { make in
            make.top.equalTo(tipLb.snp.bottom).offset(Screen_IPadMultiply(20))
            make.width.equalTo(Screen_IPadMultiply(65))
            make.height.equalTo(Screen_IPadMultiply(82))
            make.centerX.equalToSuperview()
        }
        
        // 微信
        let weChatBtn = TYShareButton()
        weChatBtn.setTitle("微信好友".yjs_translateStr(), for: .normal)
        weChatBtn.setImage(UIImage(named: "share_wechat_icon"), for: .normal)
        weChatBtn.setTitleColor(Color_Hex(0x262626), for: .normal)
        weChatBtn.titleLabel?.font = Font_System_IPadMul(15)
        weChatBtn.titleLabel?.textAlignment = .center
        weChatBtn.tag = 1
        weChatBtn.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
        bgView.addSubview(weChatBtn)
        weChatBtn.snp.makeConstraints { make in
            make.top.height.width.equalTo(friendBtn)
            make.right.equalTo(friendBtn.snp.left).offset(Screen_IPadMultiply(-55))
        }
        
        // 保存图片
        let saveImgBtn = TYShareButton()
        saveImgBtn.setTitle("保存图片".yjs_translateStr(), for: .normal)
        saveImgBtn.setImage(UIImage(named: "share_download_icon"), for: .normal)
        saveImgBtn.setTitleColor(Color_Hex(0x262626), for: .normal)
        saveImgBtn.titleLabel?.font = Font_System_IPadMul(15)
        saveImgBtn.titleLabel?.textAlignment = .center
        saveImgBtn.tag = 3
        saveImgBtn.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
        bgView.addSubview(saveImgBtn)
        saveImgBtn.snp.makeConstraints { make in
            make.top.height.width.equalTo(friendBtn)
            make.left.equalTo(friendBtn.snp.right).offset(Screen_IPadMultiply(55))
        }
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "share_close_icon"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        bgView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen_IPadMultiply(32))
            make.top.equalTo(friendBtn.snp.bottom).offset(Screen_IPadMultiply(15))
        }
    }
    
    @objc func shareClick(_ btn: UIButton) {
        switch btn.tag {
        case 1:
            shareClosure?(true, .ssFriend)
        case 2:
            shareClosure?(true, .ssTimeLine)
        case 3:
            shareClosure?(false, .ssFriend)
        default:
            break
        }
    }
    
    @objc func closeBtnClick() {
        dismissClosure?()
    }
}
