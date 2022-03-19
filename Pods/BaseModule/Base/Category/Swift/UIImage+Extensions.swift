//
//  UIImage+Extensions.swift
//  YouShaQi
//
//  Created by 杨旭 on 2019/9/5.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import YYWebImage

let yjs_ORIGINAL_MAX_WIDTH: CGFloat = 640.0

//MARK: - 颜色相关
extension UIImage {
    /// 创建颜色图片
    @objc class public func yjs_image(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect.init(origin: CGPoint.zero, size: size))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 设置图片的 tint 颜色
    @objc public func yjs_image(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1)
        let tintedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tintedImage
    }
}

//MARK: - 圆角相关
extension UIImage {
    /// 生成带圆角的图片，图片仍然是方的，但是圆角部分被遮盖
    public func yjs_imageWithCornerRadius(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        let path = UIBezierPath.init(roundedRect: rect, cornerRadius: radius)
        path.addClip()
        context?.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

//MARK: - 图片缩放
extension UIImage {
    /// 缩放图片
    class public func imageByScalingToMaxSize(sourceImage: UIImage) -> UIImage {
        if sourceImage.size.width < yjs_ORIGINAL_MAX_WIDTH {
            return sourceImage
        }
        var btWidth: CGFloat = 0
        var btHeight: CGFloat = 0
        if sourceImage.size.width > sourceImage.size.height {
            btHeight = yjs_ORIGINAL_MAX_WIDTH
            btWidth = sourceImage.size.width * (yjs_ORIGINAL_MAX_WIDTH / sourceImage.size.height)
        } else {
            btWidth = yjs_ORIGINAL_MAX_WIDTH
            btHeight = sourceImage.size.height * (yjs_ORIGINAL_MAX_WIDTH / sourceImage.size.width)
        }
        let targetSize = CGSize(width: btWidth, height: btHeight)
        return imageByScalingAndCroppingForSourceImageAndTargetSize(sourceImage: sourceImage, targetSize: targetSize)
    }
    
    class public func imageByScalingAndCroppingForSourceImageAndTargetSize(sourceImage: UIImage, targetSize: CGSize) -> UIImage {
        let newImage: UIImage?
        let imageSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        var scaleFactor: CGFloat = 0
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        if imageSize.equalTo(targetSize) == false {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContext(targetSize)
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        sourceImage.draw(in: thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if newImage == nil {
            print("could not scale image")
        }
        return newImage ?? sourceImage
    }
}

//MARK: - 图片截取
extension UIImage {
    /// 截取当前image对象rect区域内的图像
    public func yjs_subImage(rect: CGRect) -> UIImage {
        let imageRef = self.cgImage
        let newImage = imageRef?.cropping(to: rect)
        return UIImage.init(cgImage: newImage!)
    }
    
    /// UIView转化为UIImage
    class public func yjs_screenshot(view: UIView) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

//MARK: - 加载 webp
extension UIImage {
    /// 加载webp图
    public static func yjs_webpImage(imageName: String) -> UIImage? {
        let webpImage = yjs_BundleImage(name: imageName, type: "webp")
        if let imageOK = webpImage {
            return imageOK
        } else {
            let pngImage = yjs_BundleImage(name: imageName, type: "png")
            if let imageOK = pngImage {
                return imageOK
            } else {
                return UIImage(named: imageName)
            }
        }
    }
    
    ///加载本地图
    public static func yjs_BundleImage(name: String, type: String) -> UIImage? {
        let screenScale = UIScreen.main.scale
        let imageScale = screenScale <= 2.0 ? 2 : 3
        let imagePathName = name + "@\(imageScale)x"
        var path = Bundle.main.path(forResource: imagePathName, ofType: type)
        if path == nil {
            path = Bundle.main.path(forResource: name, ofType: type)
        }
        if let pathOK = path, !pathOK.isBlank {
            if let data = NSData(contentsOfFile: pathOK) {
                let decoder = YYImageDecoder(data: data as Data, scale: screenScale)
                let image = decoder?.frame(at: 0, decodeForDisplay: true)?.image
                return image
            }
        }
        return nil
    }
}

//mark:旋转相关
extension UIImage {
    
    /// 纠正图片的方向
    public func yjs_fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        let transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform.translatedBy(x: self.size.width, y: self.size.height)
            transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform.translatedBy(x: self.size.width, y: 0)
            transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform.translatedBy(x: 0, y: self.size.height)
            transform.rotated(by: -(CGFloat.pi / 2))
        case .up, .upMirrored:
            break
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: self.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: self.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        default:
            break
        }
        
        let ctx = CGContext.init(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: (self.cgImage?.colorSpace)!, bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    
    /// 按给定的方向旋转图片
    public func yjs_rotate(orient: Orientation) -> UIImage {
        let cgImg = self.cgImage
        return yjs_rotate(orient: orient, size: CGSize(width: cgImg!.width, height: cgImg!.height))
        
    }
    
    public func yjs_rotate(orient: Orientation, size: CGSize) -> UIImage {
        var bnds = CGRect.zero
        let copy: UIImage?
        let ctxt: CGContext?
        let imag = self.cgImage
        var rect = CGRect.zero
        let tran = CGAffineTransform.identity
        
        rect.size.width = size.width
        rect.size.height = size.height
        bnds = rect
        
        switch orient {
        case .up:
            return self
        case .upMirrored:
            tran.translatedBy(x: rect.width, y: 0)
            tran.scaledBy(x: -1.0, y: 1.0)
        case .down:
            tran.translatedBy(x: 0, y: rect.height)
            tran.rotated(by: .pi)
        case .downMirrored:
            tran.translatedBy(x: rect.width, y: rect.height)
            tran.scaledBy(x: 1.0, y: -1.0)
        case .left:
            bnds = swapWidthAndHeight(rect: bnds)
            tran.translatedBy(x: 0, y: rect.height)
            tran.rotated(by: 3.0 * .pi / 2.0)
        case .leftMirrored:
            bnds = swapWidthAndHeight(rect: bnds)
            tran.translatedBy(x: rect.height, y: rect.width)
            tran.scaledBy(x: -1.0, y: 1)
            tran.rotated(by: 3.0 * .pi / 2.0)
        case .right:
            bnds = swapWidthAndHeight(rect: bnds)
            tran.translatedBy(x: rect.height, y: 0)
            tran.rotated(by: .pi / 2.0)
        case .rightMirrored:
            bnds = swapWidthAndHeight(rect: bnds)
            tran.scaledBy(x: -1.0, y: 1.0)
            tran.rotated(by: .pi / 2.0)
        default:
            return self
        }
        
        UIGraphicsBeginImageContext(bnds.size)
        ctxt = UIGraphicsGetCurrentContext()
        
        switch orient {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctxt?.scaleBy(x: -1.0, y: 1.0)
            ctxt?.translateBy(x: -rect.height, y: 0)
        default:
            ctxt?.scaleBy(x: 1.0, y: -1.0)
            ctxt?.translateBy(x: 0, y: -rect.height)
        }
        
        ctxt?.concatenate(tran)
        ctxt?.draw(imag!, in: rect)
        copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy ?? self
    }
    
    /// 垂直翻转
    public func yjs_flipVertical() -> UIImage {
        return yjs_rotate(orient: .downMirrored)
    }
    
    /// 水平翻转
    public func yjs_flipHorizontal() -> UIImage {
        return yjs_rotate(orient: .upMirrored)
    }
    
    
    private func swapWidthAndHeight(rect: CGRect) -> CGRect {
        var nRect = rect
        nRect.size.width = rect.height
        nRect.size.height = rect.width
        return nRect
    }
    
}
