//
//  TYShopHotProductCell.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/13.
//

import UIKit
import BaseModule

class TYShopHotProductCell: UITableViewCell {
    
    var goProductDetailClosure: ((TYShopProductModel)->Void)?
    
    private var collectionView: UICollectionView?
    
    private var exaProducts: [TYShopProductModel]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(productModels: [TYShopProductModel]?) {
        exaProducts = productModels
        collectionView?.reloadData()
    }
}

private extension TYShopHotProductCell {
    func createSubviews() {
        contentView.backgroundColor = Color_Hex(0xF8F8F8)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = Color_Hex(0xF8F8F8)
        collectionView?.showsHorizontalScrollIndicator = false
        contentView.addSubview(collectionView!)
        collectionView?.register(TYShopHotProductCollectionCell.self, forCellWithReuseIdentifier: "TYShopHotProductCollectionCell")
        collectionView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}

extension TYShopHotProductCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exaProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TYShopHotProductCollectionCell", for: indexPath) as! TYShopHotProductCollectionCell
        if let model = exaProducts?[indexPath.item] {
            cell.updateCell(model: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type = TYUserInfoHelper.getUserType()
        if type == 2 {
            // 合伙人
            return CGSize(width: Screen_IPadMultiply(155), height: Screen_IPadMultiply(254))
        } else {
            return CGSize(width: Screen_IPadMultiply(155), height: Screen_IPadMultiply(224))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Screen_IPadMultiply(10), bottom: 0, right: Screen_IPadMultiply(10))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = exaProducts?[safely: indexPath.item] {
            goProductDetailClosure?(model)
        }
    }
}
