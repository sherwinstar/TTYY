//
//  TYContactUsVC.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/12.
//

import UIKit
import BaseModule

class TYContactUsVC: TYBaseVC {
    let QRCodeUrl = "https://statics.zhuishushenqi.com/ttyy/image/code.png"
    
    private var qrImgV = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubView()
    }
}

private extension TYContactUsVC {
    func createSubView() {
        setupNavBar(title: "联系客服")
        qrImgV.isUserInteractionEnabled = true
        if let url = URL(string: QRCodeUrl) {
            qrImgV.sd_setImage(with: url)
        }
        view.addSubview(qrImgV)
        qrImgV.snp.makeConstraints { make in
            make.width.height.equalTo(Screen_IPadMultiply(180))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Screen_IPadMultiply(-50))
        }
        let long = UILongPressGestureRecognizer(target: self, action: #selector(saveImg))
        long.minimumPressDuration = 1
        qrImgV.addGestureRecognizer(long)
        
        let tipLb = UILabel()
        tipLb.textColor = Color_Hex(0x262626)
        tipLb.textAlignment = .center
        tipLb.font = Font_System_IPadMul(14)
        tipLb.numberOfLines = 3
        view.addSubview(tipLb)
        tipLb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(qrImgV.snp.bottom).offset(Screen_IPadMultiply(20))
        }
        tipLb.text = "说明\n长按保存二维码，微信扫一扫添加客服哦~\n咨询时间：早9：00-晚上21：00"
    }
    
    @objc func saveImg() {
        guard let img = qrImgV.image else {
            showToast(msg: "二维码未加载成功，稍后再试")
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "保存图片".yjs_translateStr(), style: .default, handler: { (_) in
            YJSPhotoUtils.saveImgToAlbum(in: self, img: img) { isSuccess in
                guard isSuccess else { return }
                YJSToast.show("保存成功")
            }
        }))
        alert.addAction(UIAlertAction(title: "取消".yjs_translateStr(), style: .cancel, handler: nil))
    
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: view.height - 200, width: view.width, height: view.height)
        present(alert, animated: true, completion: nil)
    }
}
