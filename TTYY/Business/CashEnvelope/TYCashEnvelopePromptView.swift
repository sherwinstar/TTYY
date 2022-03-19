//
//  CashEnvelopePromptView.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/20.
//

import UIKit
import BaseModule
import YJSWebModule

class TYCashEnvelopePromptView: UIView {

    private var contentView = UIView()
    
    private var type = 4
    private var tkl = ""
    
    var btnClickClosure: ((Int, String?)->Void)?
    var productInfo: TYProductInfoModel?
    
    class func show(productModel: TYProductInfoModel, type: Int, tkl: String) {
        if let subV = UIApplication.shared.keyWindow?.viewWithTag(100011) {
            subV.removeFromSuperview()
        }
        let productView = TYCashEnvelopePromptView()
        productView.tkl = tkl
        productView.type = type
        productView.createSubview(productModel)
        productView.tag = 100011
        UIApplication.shared.keyWindow?.addSubview(productView)
        productView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

private extension TYCashEnvelopePromptView {
    func createSubview(_ model: TYProductInfoModel) {
        productInfo = model
        backgroundColor = Color_HexA(0x000000, alpha: 0.6)
        addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Screen_IPadMultiply(10)
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(309), height: Screen_IPadMultiply(217)))
            make.center.equalToSuperview()
        }
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "ty_product_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        contentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: Screen_IPadMultiply(40), height: Screen_IPadMultiply(40)))
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "返现红包提示".yjs_translateStr()
        titleLabel.font = Font_Semibold_IPadMul(18)
        titleLabel.textColor = Color_Hex(0x262626)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(Screen_IPadMultiply(33))
            make.height.equalTo(Screen_IPadMultiply(25))
        }
        
        let tipLabel = UILabel()
        tipLabel.text =  "建议您先加入收藏，2小时后在收藏内购买即可获得\(productInfo?.saveMoney ?? 0)元红包返现。"
        tipLabel.numberOfLines = 2
        tipLabel.font = Font_Semibold_IPadMul(14)
        tipLabel.textColor = Color_Hex(0x595959)
        tipLabel.textAlignment = .left
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(Screen_IPadMultiply(25))
            make.right.equalTo(-Screen_IPadMultiply(25))
            make.top.equalTo(Screen_IPadMultiply(82))
            make.height.equalTo(Screen_IPadMultiply(40))
        }
        
        let buyBtn = UIButton()
        buyBtn.setTitle("立即购买", for: .normal)
        buyBtn.setTitleColor(Color_Hex(0xE11521), for: .normal)
        buyBtn.titleLabel?.font = Font_System_IPadMul(14)
        buyBtn.layer.cornerRadius = Screen_IPadMultiply(8)
        buyBtn.layer.masksToBounds = true
        buyBtn.layer.borderWidth = 1
        buyBtn.layer.borderColor = Color_Hex(0xE11521).cgColor
        buyBtn.setBackgroundColor(Color_Hex(0xFFFFFF), for: .normal)
        contentView.addSubview(buyBtn)
        buyBtn.addTarget(self, action: #selector(buyBtnClick), for: .touchUpInside)
        buyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen_IPadMultiply(14))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-31))
            make.width.equalTo(Screen_IPadMultiply(132))
            make.height.equalTo(Screen_IPadMultiply(40))
         }

        let joinBtn = UIButton()
        joinBtn.setTitle("加入收藏", for: .normal)
        joinBtn.setTitleColor(Color_Hex(0xFFFFFF), for: .normal)
        joinBtn.titleLabel?.font = Font_System_IPadMul(14)
        joinBtn.layer.cornerRadius = Screen_IPadMultiply(8)
        joinBtn.layer.masksToBounds = true
        joinBtn.setBackgroundColor(Color_Hex(0xE11521), for: .normal)
        contentView.addSubview(joinBtn)
        joinBtn.addTarget(self, action: #selector(joinBtnClick), for: .touchUpInside)
        joinBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-14))
            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-31))
            make.width.equalTo(Screen_IPadMultiply(132))
            make.height.equalTo(Screen_IPadMultiply(40))
         }
    }

    @objc func closeBtnClick() {
        removeFromSuperview()
    }
    
    @objc func buyBtnClick() {
        closeBtnClick()
        TYCopyProductHelper.goPdd(productInfo!.goodsId)
    }
    
    @objc func joinBtnClick() {
        joinInCollection()
    }
    
    func joinInCollection() {
        var params = [String: Any]()
        params["tkl"] = tkl
        let token = TYUserInfoHelper.getUserToken()
        if !token.isBlank {
            params["token"] = token
        }
        params["isCompareOrder"] = "true"
        let dict = productInfo!.kj.JSONObject()
        params.merge(dict) { (current, _) in current}
//        for (key, value) in dict {
//            params.updateValue(value, forKey: key)
//        }
        YJSSessionManager.createRequest(.newApi, method: .post, path: "/shopping/User/UserCollectionGoodsAdd", params: params).responseJSON { [weak self] isSuccess, result, error, _ in
            if let ok = result["ok"] as? Bool, ok {
                self?.showToast(msg: "已收藏".yjs_translateStr())
                self?.closeBtnClick()
                self?.goWebView(url: TYOnlineUrlHelper.getCollectionURL())
            }
        }
    }

    func goWebView(url: String) {
        let web = YJSWebStoreVC()
        web.originUrl = url
        web.webVC.needEncode = false
        web.webVC.topMargin = Screen_NavItemY
        web.setupHiddenNav()
        UIApplication.getCurrentVC()?.navigationController?.pushViewController(web, animated: true)
    }
}
