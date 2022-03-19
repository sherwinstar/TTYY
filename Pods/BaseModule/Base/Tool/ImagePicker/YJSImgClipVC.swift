//
//  YJSImgClipVC.swift
//  BaseModule
//
//  Created by Admin on 2020/9/2.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

// 截取图片以适应头像要求的视图控制器
public class YJSImgClipVC: YJSBaseVC {
    // 视图
    private var scrollView: UIScrollView!
    private var imgView: UIImageView! // 原始图片：放在scrollView中
    private var controlView: UIView! // 菜单视图：有取消和选取按钮
    // 初始化信息
    private let originImg: UIImage // 原始图片
    private var clipSize: CGSize = .zero// 指定的截取范围，也就是视图中透明的区域，将来这部分区域的图片会被截取出来
    private var completion: (UIImage?, UIViewController) -> ()
    // 方便计算用的
    private var defaultScale: CGFloat = 0 // 默认缩放比例
    
    /// 初始化截取图片的视图控制器
    /// - Parameters:
    ///   - img: 原始图片
    ///   - clipSize: 截取框大小
    ///   - completion: 截取结果，外界需要在 completion 中收起 YJSImgClipVC
    /// - Returns: YJSImgClipVC
    public init(img: UIImage, clipSize: CGSize?, completion: @escaping (UIImage?, UIViewController) -> ()) {
        self.originImg = img
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        if let size = clipSize {
            if size.width > Screen_Width || size.height > Screen_Height {
                self.clipSize = size
            } else {
                self.clipSize = self.defaultClipSize
            }
        } else {
            self.clipSize = self.defaultClipSize
        }
    }
    
    /// 默认的截取框大小
    private var defaultClipSize: CGSize {
        CGSize(width: Screen_Width, height: Screen_Width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        decideScale(according: originImg, clipSize: clipSize)
        setupView()
    }
}

//MARK: - 视图初始化
extension YJSImgClipVC {
    func setupView() {
        createControlView()
        createImgView()
        createClipView()
    }
    
    /// 菜单栏
    var controlViewHeight: CGFloat {
        44 + Screen_SafeBottomHeight
    }
    
    func createControlView() {
        controlView = UIView.init()
        view.addSubview(controlView)
        controlView.backgroundColor = Color_RGBA(20, 20, 20, 0.9)
        controlView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(controlViewHeight)
        }
        
        let contentView = UIView.init()
        contentView.backgroundColor = .clear
        controlView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let cancelBtn = UIButton.init(type: .custom)
        contentView.addSubview(cancelBtn)
        cancelBtn.setTitle("取消".yjs_translateStr(), for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = Font_System(18)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        cancelBtn.addTarget(self, action: #selector(handleCancelBtnAction), for: .touchUpInside)
        
        let confirmBtn = UIButton.init(type: .custom)
        contentView.addSubview(confirmBtn)
        confirmBtn.setTitle("选取".yjs_translateStr(), for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = Font_System(18)
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        confirmBtn.addTarget(self, action: #selector(handleConfirmBtnAction), for: .touchUpInside)
    }
    
    /// 截取框
    func createClipView() {
        let overlayView = UIView.init()
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)
        overlayView.backgroundColor = .clear
        overlayView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(controlView.snp_top)
        }
        
        // 中间的透视区域
        let blank = UIView.init()
        blank.backgroundColor = .clear
        overlayView.addSubview(blank)
        blank.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(clipSize.width)
            make.height.equalTo(clipSize.height)
        }
        
        let top = UIView.init()
        top.backgroundColor = Color_RGBA(0, 0, 0, 0.5)
        overlayView.addSubview(top)
        top.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(blank.snp_top)
        }
        
        let bottom = UIView.init()
        bottom.backgroundColor = Color_RGBA(0, 0, 0, 0.5)
        overlayView.addSubview(bottom)
        bottom.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(blank.snp_bottom)
        }
        
        let left = UIView.init()
        left.backgroundColor = Color_RGBA(0, 0, 0, 0.5)
        overlayView.addSubview(left)
        left.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(top.snp_bottom)
            make.bottom.equalTo(bottom.snp_top)
            make.right.equalTo(blank.snp_left)
        }
        
        let right = UIView.init()
        right.backgroundColor = Color_RGBA(0, 0, 0, 0.5)
        overlayView.addSubview(right)
        right.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(top.snp_bottom)
            make.bottom.equalTo(bottom.snp_top)
            make.left.equalTo(blank.snp_right)
        }
    }
    
    /// 图片
    func createImgView() {
        scrollView = UIScrollView.init()
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(controlView.snp_top)
        }
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            edgesForExtendedLayout = []
        }
        
        let scrollWidth = view.swift_width
        let scrollHeight = view.swift_height - controlViewHeight
        // 设置contentInset：因为有截取范围，所以scrollView的显示区域不是scrollView的frame
        let verticalInsert = (scrollHeight - clipSize.height) / 2.0
        let horizonInsert = (scrollWidth - clipSize.width) / 2.0
        scrollView.contentInset = UIEdgeInsets(top: verticalInsert, left: horizonInsert, bottom: verticalInsert, right: horizonInsert)
        
        // 设置缩放比例，让scrollView处理缩放
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        
        imgView = UIImageView.init()
        scrollView.addSubview(imgView)
        // 图片：默认缩放至 scaleAspectFill
        let imgWidth = originImg.size.width * defaultScale
        let imgHeight = originImg.size.height * defaultScale
        imgView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
        }
        imgView.image = originImg
        
        // 设置contentSize以能：通过滑动显示出图片的全部内容
        scrollView.contentSize = CGSize(width: max(imgWidth, scrollWidth), height: max(imgHeight, scrollHeight))
        let offsetX = (imgWidth - scrollWidth) / 2.0
        let offsetY = (imgHeight - scrollHeight) / 2.0
        // 设置contentOffset：默认把图片显示在正中间
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    func decideScale(according img: UIImage, clipSize: CGSize) {
        let widthScale: CGFloat = clipSize.width / img.size.width
        let heightScale: CGFloat = clipSize.height / img.size.height
        if widthScale > heightScale {
            defaultScale = widthScale
        } else {
            defaultScale = heightScale
        }
    }
}

//MARK: - 菜单视图事件处理
extension YJSImgClipVC {
    @objc func handleCancelBtnAction() {
        completion(nil, self)
    }
    
    @objc func handleConfirmBtnAction() {
        completion(getEditedImg(), self)
    }
    
    /// 截取图片
    func getEditedImg() -> UIImage? {
        // 计算截取范围
        let scale = originImg.size.width / imgView.swift_width
        let offset = scrollView.contentOffset
        let clipX = (view.swift_width - clipSize.width) / 2.0
        let clipY = (view.swift_height - clipSize.height) / 2.0
        let visibleRect = CGRect(x: offset.x + clipX, y: offset.y + clipY, width: clipSize.width, height: clipSize.height)
        let rect: CGRect = CGRect(x: visibleRect.origin.x * scale,
                                  y: visibleRect.origin.y * scale,
                                  width: visibleRect.size.width * scale,
                                  height: visibleRect.size.height * scale)
        guard let imageRef = originImg.cgImage, let subImageRef = imageRef.cropping(to: rect) else {
            return nil
        }
        let size = CGSize(width: rect.width, height: rect.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.draw(subImageRef, in: rect)
        let smallImage = UIImage(cgImage: subImageRef)
        UIGraphicsEndImageContext()
        return smallImage
    }
}

//MARK: - 放大代理
extension YJSImgClipVC: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imgView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.contentSize = CGSize(width: originImg.size.width * scale * defaultScale, height: originImg.size.height * scale * defaultScale)
    }
}
