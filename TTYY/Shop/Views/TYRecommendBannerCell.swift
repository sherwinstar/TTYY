//
//  TYRecommendBannerCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

class TYRecommendBannerCell: UITableViewCell {
    var bannerActionClosure: (()->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubview()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TYRecommendBannerCell {
    func createSubview() {
        let scroll = UIScrollView()
        scroll.bounces = false
        scroll.isPagingEnabled = true
        scroll.contentSize = CGSize(width: Screen_Width * 2, height: 0)
        scroll.showsHorizontalScrollIndicator = false
        contentView.addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        
        let image1 = UIImageView()
        image1.isUserInteractionEnabled = true
        scroll.addSubview(image1)
        image1.snp.makeConstraints { make in
            make.top.left.width.height.equalToSuperview()
        }
        let image1URL = "http://statics.zhuishushenqi.com/ttyy/image/banner_1.jpg"
        if let url1 = URL(string: image1URL) {
            image1.sd_setImage(with: url1)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        image1.addGestureRecognizer(tap)
        
        let image2 = UIImageView()
        scroll.addSubview(image2)
        image2.snp.makeConstraints { make in
            make.top.width.height.equalTo(image1)
            make.left.equalTo(image1.snp.right)
        }
        let image2URL = "http://statics.zhuishushenqi.com/ttyy/image/banner_2.jpg"
        if let url2 = URL(string: image2URL) {
            image2.sd_setImage(with: url2)
        }
    }
    
    @objc func tapAction() {
        bannerActionClosure?()
    }
}
