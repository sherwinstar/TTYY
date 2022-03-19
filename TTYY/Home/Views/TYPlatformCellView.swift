//
//  TYPlatformCellView.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/6.
//

import UIKit
import BaseModule

class TYPlatformCellView: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let tipLabel = UILabel()
    let packetLabel = UILabel()
    var platformActionClosure: ((TYPlatformType)->Void)?
    var platformType : TYPlatformType = .eleme
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(title: String, image: UIImage, tip: String, tipPost: String, packet: String, backgroundColor: UIColor) {
        imageView.image = image
        self.backgroundColor = backgroundColor
        titleLabel.text = title
        titleLabel.snp.updateConstraints { make in
            make.width.equalTo(titleLabel.intrinsicContentSize.width + 2)
        }
        if !packet.isBlank {
            packetLabel.isHidden = false
            packetLabel.text = packet
            packetLabel.frame = CGRect(x: Screen_IPadMultiply(46) + titleLabel.intrinsicContentSize.width + 2, y: Screen_IPadMultiply(11), width: packetLabel.intrinsicContentSize.width + 8, height: Screen_IPadMultiply(18))
            let corners = CornerRadius(topLeft: Screen_IPadMultiply(18) / 2, topRight: Screen_IPadMultiply(18) / 2, bottomLeft: Screen_IPadMultiply(2), bottomRight: Screen_IPadMultiply(18) / 2)
            packetLabel.addCorner(cornerRadius: corners, borderColor: UIColor.white, borderWidth: 1)
            
//            packetLabel.snp.makeConstraints { make in
//                make.height.equalTo(Screen_IPadMultiply(18))
//                make.width.equalTo(Screen_IPadMultiply(packetLabel.intrinsicContentSize.width + 8))
//                make.top.equalTo(Screen_IPadMultiply(11))
//                make.left.equalTo(Screen_IPadMultiply(46) + titleLabel.intrinsicContentSize.width + 2)
//            }
            packetLabel.setAnchorPoint(CGPoint(x: 0, y: 1))
            packetLabel.pulse2(withDuration: 0.8)
        } else {
            packetLabel.isHidden = true
        }
        let moneyStr = String(format: "%@%@", tip, tipPost)
        let attrString = NSMutableAttributedString(string: moneyStr)
    
        let strSubAttr1: [NSMutableAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6,alpha:1.0)]
        attrString.addAttributes(strSubAttr1, range: NSRange(location: 0, length: tip.count))

        let strSubAttr2: [NSMutableAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),.foregroundColor: UIColor(red: 0.85, green: 0.15, blue: 0.15,alpha:1.0)]
        attrString.addAttributes(strSubAttr2, range: NSRange(location: tip.count, length: tipPost.count))

        tipLabel.attributedText = attrString
    }

}

private extension TYPlatformCellView {
    func createSubviews() {
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(tipLabel)
        self.addSubview(packetLabel)
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.height.equalTo(Screen_IPadMultiply(30))
            make.width.equalTo(Screen_IPadMultiply(30))
            make.top.equalTo(Screen_IPadMultiply(17))
            make.left.equalTo(Screen_IPadMultiply(10))
        }
        titleLabel.textAlignment = .left
        titleLabel.font = Font_Medium_IPadMul(14)
        titleLabel.textColor = UIColor.init(rgbHex: 0x260D13)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(Screen_IPadMultiply(14))
            make.width.equalTo(titleLabel.intrinsicContentSize.width + 2)
            make.top.equalTo(Screen_IPadMultiply(15))
            make.left.equalTo(Screen_IPadMultiply(46))
        }
        tipLabel.textAlignment = .left
        tipLabel.font = Font_Regular_IPadMul(12)
        tipLabel.snp.makeConstraints { make in
            make.height.equalTo(Screen_IPadMultiply(12))
            make.right.equalTo(-2)
            make.bottom.equalTo(Screen_IPadMultiply(-15))
            make.left.equalTo(Screen_IPadMultiply(46))
        }
        packetLabel.textAlignment = .center
        packetLabel.textColor = .white
        packetLabel.backgroundColor = UIColor.init(rgbHex: 0xF7313D)
        packetLabel.font = Font_Medium_IPadMul(10)
        packetLabel.layer.masksToBounds = true
    }
    
    func addGesture () {
        self.isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(platformClick)))
    }
    
    @objc func platformClick() {
        platformActionClosure?(platformType)
        TYThirdConvertHelper.goThird(platformType)
    }
}
