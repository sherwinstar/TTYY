//
//  YJSNavProtocol.swift
//  BaseModule
//
//  Created by Admin on 2020/9/15.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import SnapKit

//MARK: - 导航栏题目定义
@objc public class YJSNavItemContent: NSObject {
    let title: String?
    let localImgName: String?
    let netImgUrl: String?
    let identifier: String?
    
    @objc public init(title: String?, localImgName: String?, netImgUrl: String?, identifier: String?) {
        self.title = title
        self.localImgName = localImgName
        self.netImgUrl = netImgUrl
        self.identifier = nil
        super.init()
    }
    
    @objc public convenience init(title: String?) {
        self.init(title: title, localImgName: nil, netImgUrl: nil, identifier: nil)
    }
    
    @objc public convenience init(localImgName: String?) {
        self.init(title: nil, localImgName: localImgName, netImgUrl: nil, identifier: nil)
    }
}

//MARK: - 导航栏配置 Key
public struct YJSNavConfigKey: Hashable {
    private let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

//MARK: - 导航栏协议定义
/*
 1. 这个协议不是为了涵盖所有的情况，否则协议会太复杂，太细节
 2. 左侧按钮支持多个，
    虽然大部分情况下都是一个，但是如果就定义成一个的话，一旦碰到多个的情况，就不容易扩展了，只怕要另起炉灶，这样不好，而且定义成数组，也很容易
 3. 不提供单个按钮更新的方法：按钮的更新内容不定，所以还得通过config传参数，与其这样不如直接提供获取到按钮的方法
 */
public typealias YJSNavBtnHandler = (Int) -> ()
public protocol YJSNavProtocol: UIView {
    /// 初始化
    /// - Parameters:
    ///   - title: 题目
    ///   - leftBtns: 左边按钮，列表中不能出现同类型的
    ///   - rightBtns: 右边按钮，列表中不能出现同类型的
    ///   - config: 其他配置
    init(title: YJSNavItemContent?, leftBtns: [YJSNavItemContent]?, rightBtns: [YJSNavItemContent]?, handler: (YJSNavBtnHandler)?, config: [YJSNavConfigKey : Any]?)
    
    /// 更新题目
    /// - Parameter title: 题目
    func update(title: YJSNavItemContent, config: [YJSNavConfigKey : Any]?)
    
    /// 更新按钮列表，会把原来的按钮都移除掉，再创建新的
    /// - Parameters:
    ///   - btns: 按钮列表
    ///   - isLeft: 是左边的按钮还是右边的按钮
    func update(btns: [YJSNavItemContent], isLeft: Bool, config: [YJSNavConfigKey : Any]?)
    
    /// 更新右边按钮的handler
    /// - Parameter btnAction: handler
    func updateRight(btnAction: @escaping YJSNavBtnHandler)
    
    /// 更新左边按钮的handler
    /// - Parameter btnAction: handler
    func updateLeft(btnAction: @escaping YJSNavBtnHandler)
            
    /// 更新某些配置
    /// - Parameter config: 配置
    func update(config: [YJSNavConfigKey : Any])
    
    /// 展示固定的样式：有些导航栏会在 scrollView.contentOffset.y == 0 时，展示一种悬浮的样式，比如背景色为透明
    /// 在 scrollView.contentOffset.y > nav.height 时，展示固定样式
    func showFixedView()
    
    /// 视图控制器的 view 的 y 滑动到某个位置
    /// - Parameter offset: y
    func didScroll(to offset: CGFloat)
    
    /// 根据位置获取右侧按钮
    /// - Parameter index: 默认的 index 是从左往右依次增加，从0开始
    func getBtn(at index: Int, atRight: Bool) -> UIButton?
        
    /// 导航栏高度
    var navHeight: CGFloat { get }
    
    /// 导航栏是否覆盖在视图控制器内容之上（是：view.top == nav.top，否: view.top == nav.bottom）
    var isOverlayContent: Bool { get }
        
    /// 右边按钮
    var rightBtns: [UIButton]? { get }
    
    /// 右边按钮的handler
    var rightHandler: YJSNavBtnHandler? { set get }
    
    /// 左边按钮的handler
    var leftHandler: YJSNavBtnHandler? { set get }
    
    /// 导航栏可以指定电池掉样式，返回空，表示不指定
    var preferredStatusBarStyle: UIStatusBarStyle? { get }
    
    /// 导航栏可以指定是否显示电池条，返回空，表示不指定
    var prefersStatusBarHidden: Bool? { get }
}

// 测试
extension YJSNavProtocol {
    public func update(title: YJSNavItemContent, config: [YJSNavConfigKey : Any]?) {}
       
    public func update(btns: [YJSNavItemContent], isLeft: Bool, config: [YJSNavConfigKey : Any]?) {}
               
    public func update(config: [YJSNavConfigKey : Any]) {}
    
    public func showFixedView() {}
       
    public func didScroll(to offset: CGFloat) {}
       
    public func getBtn(at index: Int, atRight: Bool) -> UIButton? { nil }
           
    public func updateRight(btnAction: @escaping YJSNavBtnHandler) {
        rightHandler = btnAction
    }
    
    public func updateLeft(btnAction: @escaping YJSNavBtnHandler) {
        leftHandler = btnAction
    }
    
    public func getRightBtn(at index: Int) -> UIButton? {
        if let btns = rightBtns, btns.count > index {
            return btns[index]
        } else {
            return nil
        }
    }
           
    public var navHeight: CGFloat { Screen_NavHeight }
    
    public var isOverlayContent: Bool { false }
    
    public var rightBtns: [UIButton]? { nil }
    
    public var preferredStatusBarStyle: UIStatusBarStyle? { nil }
    
    public var prefersStatusBarHidden: Bool? { nil }
    
}
