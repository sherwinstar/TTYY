//
//  TYNavBarView.swift
//  TTYY
//
//  Created by YJPRO on 2021/6/4.
//

import UIKit
import BaseModule

class TYNavBarView: UIView {
    typealias tapOnIndexBlock = (Int) -> Void
    enum TYNavBarColorStyle {
        case WhiteDefault
        case Yellow
        case Clear //透明
        case Slide //用于福利社
    }
    var MaxCenterViewWScaleToBar = { return Screen_iPhoneSE ? 0.4 : 0.6 }()
    let BarSegmentItemW = 65
    let BarSegmentItemH = 25
    let BarLeftItemPhoneMargin = 0
    let BarLeftItemPadMargin = 0
    let BarRightBtnBaseTag = 20190304
    var colorStyle: TYNavBarColorStyle = .WhiteDefault
    
    var segementSelectBlock: tapOnIndexBlock?
    var leftBarItemBlock: tapOnIndexBlock?
    var rightBarItemBlock: tapOnIndexBlock?
    
    var centerTitleLabel: UILabel?
    var centerSegment: UISegmentedControl?//选择器
    var barBottomLineView: UIView?//底部分隔线
    var leftItemBtn: UIButton?
    var centerCustomView: UIView?//当前的CenterView(label/segment/customV)
    var leftBarItemView: UIButton?//当前左边的ItemView
    var rightItemsViewAry = [UIButton]()//当前的右边所有的ItemViews
    var segementAry = [String]()
    
    
    var barBgColor = UIColor.white
    var barCenterTitleColor =  Color_RGB(51, 51, 51)
    var barBottomLineColor =  Color_RGB(170, 170, 170)
    var barItemNormalColor = UIColor.black
    var barItemHighlightedColor = UIColor.black
    var rightBarItemColor = UIColor.black
    override init(frame: CGRect) {
        super.init(frame: frame)
        ty_adjustNavBar(.WhiteDefault)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 导航栏风格设置
    func ty_adjustNavBar(_ colorStyle: TYNavBarColorStyle) {
        ty_adjustNavBar(colorStyle: colorStyle, centerTitle: "")
    }
    
    func ty_adjustNavBar(colorStyle: TYNavBarColorStyle, centerTitle: String) {
        ty_adjustNavBar(colorStyle: colorStyle, centerTitle: centerTitle, centerTitleFont: Font_Semibold(17))
    }
    
    func ty_adjustNavBar(colorStyle: TYNavBarColorStyle, centerBigTitle: String) {
        ty_adjustNavBar(colorStyle: colorStyle, centerTitle: centerBigTitle, centerTitleFont: Font_Semibold(20))
    }
    
    func ty_adjustNavBar(colorStyle: TYNavBarColorStyle, centerTitle: String, centerTitleFont: UIFont) {
        self.colorStyle = colorStyle
        switch colorStyle {
            case .WhiteDefault:
                self.barBgColor = UIColor.white
                self.barCenterTitleColor =  Color_RGB(51, 51, 51)
                self.barBottomLineColor =  Color_RGB(170, 170, 170)
                self.barItemNormalColor = UIColor.black
                self.barItemHighlightedColor = UIColor.black
            
            case .Yellow:
                self.barBgColor = kThemeYellow
                self.barCenterTitleColor = UIColor.black
                self.barBottomLineColor =  Color_RGB(133, 11, 11)
                self.barItemNormalColor = UIColor.black
                self.barItemHighlightedColor = UIColor.black
            case .Clear:
                self.barBgColor = .clear
                self.barCenterTitleColor = .black
                self.barBottomLineColor = Color_RGB(133, 11, 11)
                self.barItemNormalColor = .black
                self.barItemHighlightedColor = .black
            case .Slide:
                self.barBgColor = .clear
                self.barCenterTitleColor = .white
                self.barBottomLineColor = Color_RGB(133, 11, 11)
                self.barItemNormalColor = .white
                self.barItemHighlightedColor = .white
                

        }
        self.backgroundColor = self.barBgColor
        ty_adjustCenterTitle(centerTitle, centerTitleFont: centerTitleFont)
    }
    
    ///更新导航栏背景
    fileprivate func ty_updateNavBar(bgColor: UIColor) {
        self.backgroundColor = bgColor
        self.barBgColor = bgColor
    }
    
    ///更新导航栏title的颜色
    func ty_updateCenter(titleColor: UIColor) {
        self.centerTitleLabel?.textColor = titleColor
        self.barCenterTitleColor = titleColor
    }
    
    func ty_updateLeftIcon(isWhite: Bool) {
        if isWhite {
            let image = UIImage(named: "nav_back")?.yjs_image(tintColor: .white)
            self.leftItemBtn?.setImage(image, for: .normal)
            self.leftItemBtn?.setImage(image, for: .highlighted)
        } else {
            let image = UIImage(named: "nav_back")?.yjs_image(tintColor: .black)
            self.leftItemBtn?.setImage(image, for: .normal)
            self.leftItemBtn?.setImage(image, for: .highlighted)
        }
    }
    
    ///更新导航栏右侧文字按钮颜色
    fileprivate func ty_updateRightBar(itemColor: UIColor) {
        self.rightBarItemColor = itemColor
    }
    
    //MARK: - 导航栏Center设置
    fileprivate func ty_adjustSegement(segementTitles: [String], clickBlock:@escaping (Int) -> Void) {
        if (segementTitles.isEmpty) {
            return
        }

        self.segementSelectBlock = clickBlock

        self.segementAry = segementTitles
        ty_removeOldCenterView()
        ty_createCenterSegementContol()
    }
    
    ///设置导航栏中间的Title
    open func ty_adjustCenterTitle(_ centerTitle: String) {
        ty_adjustCenterTitle(centerTitle, centerTitleFont: Font_Semibold(17))
    }
    
    fileprivate func ty_adjustCenterTitle(_ centerTitle: String, centerTitleFont: UIFont) {
        if centerTitle.isBlank {
            return;
        }
        ty_removeOldCenterView()
        ty_createCenterTitleLabel(title: centerTitle, font: centerTitleFont)
    }
    
    ///设置导航栏中间View
    fileprivate func ty_adjustCenterView(centerView: UIView) {
        ty_removeOldCenterView()
        addSubview(centerView)
        self.centerCustomView = centerView;
    }
    
    fileprivate func ty_updateNavBottomLineColor(color: UIColor) {
        self.barBottomLineView!.backgroundColor = color
    }
    
    //MARK: - 设置右Items
    ///导航右侧图片 最多设置3个
    func ty_adjustRightBarItems(normalImageNames: [String], highlightedImgNames: [String], rightClickBlock:@escaping (Int) -> Void) {
        ty_removeOldRightViews()
        self.rightBarItemBlock = rightClickBlock;
        ty_creatRightBtns(isTitleBtn: false, isCustomBtn: false, customViews: [], titleStrArys: [], normalImgNames: normalImageNames, helightedNames: highlightedImgNames)
    
    }
    
    ///导航右侧为文字
    func ty_adjustRightBarItems(titles: [String], rightClickBlock:@escaping (Int) -> Void) {
        ty_removeOldRightViews()
        self.rightBarItemBlock = rightClickBlock
        ty_creatRightBtns(isTitleBtn: true, isCustomBtn: false, customViews: [], titleStrArys: titles, normalImgNames: [], helightedNames: [])
    
    }
    
    ///导航右侧为自定义按钮
    func ty_adjustRightBarItem(customBtns: [UIButton], rightClickBlock: tapOnIndexBlock?) {
        ty_removeOldRightViews()
        self.rightBarItemBlock = rightClickBlock
        ty_creatRightBtns(isTitleBtn: false, isCustomBtn: true, customViews: customBtns, titleStrArys: [], normalImgNames: [], helightedNames: [])
    }
    
    //MARK: - 设置左侧Item
    ///返回按钮设置
    open func ty_adjustLeftItem(backTitle: String, backArrow: Bool, leftClick: tapOnIndexBlock?) {
        ty_removeOldLeftView()
        ty_createLeftBtn()
    
        self.leftBarItemBlock = leftClick;
    
        var leftItemBtnW: CGFloat = 44.0
        if (backArrow) {
            let normalImage = ty_createImage(title: backTitle, isHighlight: false, isConstraintTitleWidth: true)
            self.leftItemBtn!.setImage(normalImage, for: .normal)
            
            let highlightedImage = ty_createImage(title: backTitle, isHighlight: true, isConstraintTitleWidth: true)
            self.leftItemBtn!.setImage(highlightedImage, for: .highlighted)
            leftItemBtnW = normalImage.size.width
        } else {
            self.leftItemBtn!.setTitle(backTitle, for: .normal)
            let titleSize = ty_calculateSize(str: backTitle, font: Font_Bold(15))
            leftItemBtnW = titleSize.width + 30.0
        }
        self.leftItemBtn!.setTitleColor(self.barItemNormalColor, for: .normal)
        self.leftItemBtn!.setTitleColor(self.barItemHighlightedColor, for: .highlighted)
        let leftMargin = Screen_IPAD ? BarLeftItemPadMargin : BarLeftItemPhoneMargin;
        self.leftItemBtn!.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(Screen_NavItemY);
            make.left.equalTo(self).offset(leftMargin);
            make.width.equalTo(leftItemBtnW);
            make.bottom.equalTo(self);
        }
    }
    
    ///设置左边的ItemImg
    fileprivate func ty_adjustLeftBarItem(normalImgName: String, hightLightedImgName: String, leftClick: tapOnIndexBlock?) {
        if normalImgName.isBlank {
            ty_removeOldLeftView()
            return;
        }
        ty_removeOldLeftView()
        ty_createLeftBtn()
    
        self.leftBarItemBlock = leftClick;
    
        let normalImage = UIImage(named: normalImgName)
        let highlightedImage = UIImage(named: hightLightedImgName)
        self.leftItemBtn!.setImage(normalImage, for: .normal)
        self.leftItemBtn!.setImage(highlightedImage, for: .highlighted)
    
        let leftMargin = Screen_IPAD ? BarLeftItemPadMargin : BarLeftItemPhoneMargin;
        let leftItemBtnW = max(normalImage!.size.width, 44);
        self.leftItemBtn!.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(Screen_NavItemY);
            make.left.equalTo(self).offset(leftMargin);
            make.width.equalTo(leftItemBtnW);
            make.bottom.equalTo(self);
        }
    }
    
    ///设置左边的Item用View
    fileprivate func ty_adjustLeftBarItem(leftItemView: UIButton?, leftClick: tapOnIndexBlock?) {
        if (leftItemView == nil) {
            ty_removeOldLeftView()
            return;
        }
        ty_removeOldLeftView()
        self.leftBarItemView = leftItemView
        self.leftBarItemBlock = leftClick
        
        addSubview(leftItemView!)
    
        let leftMargin = Screen_IPAD ? BarLeftItemPadMargin : BarLeftItemPhoneMargin
        leftItemView!.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(Screen_NavItemY);
            make.left.equalTo(self).offset(leftMargin);
            make.width.equalTo(self).multipliedBy(0.24);//左边按钮最宽4个字
            make.bottom.equalTo(self);
        }
    }
    
    //MARK: - 获取SegmentControl相关信息
    ///获取当前选中的选择器index
    fileprivate func ty_getCurrentSelectedSegmentIndex() -> Int {
        return self.centerSegment!.selectedSegmentIndex;
    }
    
    ///更新选中的index(滑动切换时要用到)
    fileprivate func ty_updateSegmentControl(index: Int) {
        if (index < self.segementAry.count) {
            self.centerSegment!.selectedSegmentIndex = index
        }
    }
    
    ///是否需要显示导航栏底部分割线 默认NO
    fileprivate func ty_needShowNavBarBottomLine(showLine: Bool) {
        if (showLine) {
            ty_createBottomLine()
        } else {
            self.barBottomLineView!.removeFromSuperview()
            self.barBottomLineView = nil
        }
    }
    
    //MARK: - ================= Pricate Method =================
    //MARK: - 创建子视图
    fileprivate func ty_createLeftBtn() {
        if (self.leftBarItemView == nil) {
            self.leftItemBtn = UIButton()
            self.leftItemBtn!.titleLabel?.font = Font_System(15)
            self.leftItemBtn!.addTarget(self, action: #selector(ty_userTapLeftBarItem(leftBtn:)), for: .touchUpInside)
            self.leftBarItemView = self.leftItemBtn;
        }
        if (self.leftItemBtn!.superview == nil) {
            addSubview(self.leftBarItemView!)
        }
    }
    
    fileprivate func ty_createCenterTitleLabel(title: String, font: UIFont) {
        if (self.centerTitleLabel == nil) {
            self.centerTitleLabel = UILabel()
            addSubview(self.centerTitleLabel!)
            self.centerTitleLabel!.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(Screen_NavItemY);
                make.bottom.equalTo(self);
                //优先考虑最大可能情况 - 会更新
                make.width.lessThanOrEqualTo(self).multipliedBy(MaxCenterViewWScaleToBar);
            })
        }
        self.centerTitleLabel!.isHidden = false
        self.centerTitleLabel!.font = font
        self.centerTitleLabel!.textAlignment = .center
        self.centerTitleLabel!.text = title;
        self.centerTitleLabel!.textColor = self.barCenterTitleColor
    }
    
    fileprivate func ty_creatRightBtns(isTitleBtn: Bool, isCustomBtn: Bool, customViews: [UIButton], titleStrArys: [String], normalImgNames: [String], helightedNames: [String]) {
        self.rightItemsViewAry.removeAll()
        var btnCount = 0
        if isTitleBtn {
            btnCount = titleStrArys.count
        } else {
            if isCustomBtn {
                btnCount = customViews.count
            } else {
                btnCount = normalImgNames.count
            }
        }
        let btnFont = Font_System(15)
        var lastView: UIButton?
        for i in 0 ..< btnCount {
            var tempBtn: UIButton
            if (isCustomBtn) {
                tempBtn = customViews[i];
            } else {
                tempBtn = UIButton()
                tempBtn.titleLabel!.font = btnFont;
            }
            addSubview(tempBtn)
            
            
            var tempBtnMaxW: CGFloat = 44.0
            if (isTitleBtn) {
                let tempBtnTitle = titleStrArys[i]
                let titleSize: CGSize = ty_calculateSize(str: tempBtnTitle, font: btnFont)
                tempBtnMaxW = max(titleSize.width + 30, 44)
                tempBtn.setTitle(tempBtnTitle, for: .normal)
                tempBtn.setTitleColor(self.rightBarItemColor, for: .normal)
            } else if (isCustomBtn) {
                tempBtnMaxW = tempBtn.frame.size.width
            } else {
                let normalImg = UIImage(named: normalImgNames[i])
                tempBtnMaxW = max(normalImg!.size.width, 44)
                tempBtn.setImage(normalImg, for: .normal)
                if (i < helightedNames.count) {
                    let heightedImg = UIImage(named: helightedNames[i])
                    tempBtn.setImage(heightedImg, for: .highlighted)
                }
            }
            tempBtn.snp.makeConstraints({ (make) in
                make.top.equalTo(self).offset(Screen_NavItemY);
                if ((lastView) != nil) {
                    make.right.equalTo(lastView!.snp.left).offset(5);
                } else {
                    make.right.equalTo(self.snp.right).offset(-10);
                }
                make.width.equalTo(tempBtnMaxW);
                make.bottom.equalTo(self);
            })
            tempBtn.tag = BarRightBtnBaseTag + i
            tempBtn.addTarget(self, action: #selector(ftxs_userTapRightBarItem(rightBtn:)), for: .touchUpInside)
            lastView = tempBtn
            self.rightItemsViewAry.append(tempBtn)
        }
    
        self.centerCustomView?.snp.makeConstraints { (make) in
            if (self.leftBarItemView != nil) {
                make.left.equalTo(self.leftBarItemView!.snp.right);
            } else {
                make.left.equalTo(self);
            }
            make.top.equalTo(self).offset(Screen_NavItemY);
            if (self.centerCustomView != nil) {
                make.height.equalTo(self.centerCustomView!);
            } else {
                make.height.equalTo(self);
            }
        }
    }
    
    fileprivate func ty_createBottomLine() {
        if self.barBottomLineView == nil {
            self.barBottomLineView = UIView()
            self.barBottomLineView!.backgroundColor = self.barBottomLineColor;
            addSubview(self.barBottomLineView!)
            self.barBottomLineView!.snp.makeConstraints { (make) in
                make.left.right.equalTo(self);
                make.height.equalTo(0.5);
                make.bottom.equalTo(self).offset(-0.5);
            }
        }
    }
    
    fileprivate func ty_createCenterSegementContol() {
        if (self.centerSegment == nil) {
            self.centerSegment = UISegmentedControl()
            self.centerSegment!.addTarget(self, action: #selector(ftxs_userTapSegment(segmentControl:)), for: .valueChanged)
            addSubview(self.centerSegment!)
            self.centerSegment!.tintColor = self.barItemNormalColor
            
            let segmentCount = self.segementAry.count;
            if (self.centerSegment!.numberOfSegments != segmentCount) {
                for i in 0..<segmentCount {
                    let title = self.segementAry[i]
                    self.centerSegment!.insertSegment(withTitle: title, at: i, animated: false)
                }
            }
            let centerSegementW = segmentCount * BarSegmentItemW;
            self.centerSegment!.snp.makeConstraints { (make) in
                make.centerX.equalTo(self);
                make.top.equalTo(Screen_NavItemY);
                make.width.equalTo(centerSegementW);
                make.height.equalTo(BarSegmentItemH);
            }
            self.centerCustomView = self.centerSegment;
        }
    }
    
    //MARK: - 移除旧的View
    fileprivate func ty_removeOldCenterView() {
        if (self.centerCustomView != nil) {
            self.centerCustomView!.removeFromSuperview()
            self.centerCustomView = nil
        }
        if (self.centerTitleLabel != nil) {
            self.centerTitleLabel!.isHidden = true;
        }
    }
    
    fileprivate func ty_removeOldLeftView() {
        if (self.leftBarItemView != nil) {
            self.leftBarItemView!.removeFromSuperview()
            self.leftBarItemView = nil;
        }
    }
    
    fileprivate func ty_removeOldRightViews() {
        if (self.rightItemsViewAry.count > 0) {
            for rightSubV in self.rightItemsViewAry {
                rightSubV.removeFromSuperview()
            }
            self.rightItemsViewAry.removeAll()
        }
    }
    
    //MARK: - 按钮点击事件
    @objc func ftxs_userTapSegment(segmentControl: UISegmentedControl) {
        if let tapBlock = self.segementSelectBlock {
            tapBlock(segmentControl.selectedSegmentIndex);
        }
    }
    
    @objc func ty_userTapLeftBarItem(leftBtn: UIButton) {
        if let tapBlock = self.leftBarItemBlock {
            tapBlock(0)
        }
    }
    
    @objc func ftxs_userTapRightBarItem(rightBtn: UIButton) {
        if let tapBlock = self.rightBarItemBlock {
            let tapIndex = rightBtn.tag - BarRightBtnBaseTag;
            tapBlock(tapIndex)
        }
    }
    
    //MARK: - 返回按钮生成
    fileprivate func ty_createImage(title: String, isHighlight: Bool, isConstraintTitleWidth:Bool) -> UIImage {
        let textFont = Font_System(15)
        let textSize: CGSize = ty_calculateSize(str: title, font: textFont)
        var textWidth: CGFloat = 0.0;
        if (isConstraintTitleWidth) {
            textWidth = textSize.width + 35.0;
        } else {
            textWidth = (textSize.width >= 55.0 ? 90.0 : 75.0);
        }
        
        let imgSize = CGSize(width: textWidth, height: 44.0)
        let textRect = CGRect(x: 35.0, y: 13.5, width: (textWidth - 25.0), height: 16.0)
        
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale);
        
        var originImage: UIImage
        switch (self.colorStyle) {
            case .Yellow, .Clear:
                originImage = UIImage(named: "nav_back_white")!
                break;
            
        case .WhiteDefault, .Slide:
                originImage = UIImage(named: "nav_back")!
                break;
        }
        originImage.draw(at: CGPoint(x: 15.0, y: 10.0))
        
        let backLabel = UILabel.init(frame: textRect)
        backLabel.backgroundColor = UIColor.clear
        backLabel.font = textFont;
        if (isHighlight) {
            backLabel.textColor = self.barItemHighlightedColor;
        } else {
            backLabel.textColor = self.barItemNormalColor;
        }
        backLabel.text = title;
        backLabel.drawText(in: backLabel.frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
    
    fileprivate func ty_calculateSize(str: String, font: UIFont) -> CGSize {
        let rect = (str as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
}
