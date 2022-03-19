//
//  YJAvaterView.h
//  BaseModule
//
//  Created by Admin on 2020/10/19.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YJAvaterView;

@protocol YJAvaterViewDelegate <NSObject>

- (void)avaterViewDidClick:(YJAvaterView *)avaterView;

@end


NS_ASSUME_NONNULL_BEGIN

@interface YJAvaterView : UIImageView

/// 初始化
/// @param frame frame，自动布局时传进来.zero就可以了
/// @param radius 圆角大小
/// @param url 完整地址
/// @param delegate 如果可以被点击，需要有代理，如果不可以被点击，不传代理。是否可以被点击，是在初始化时就确定的，后面不能再修改
- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius url:(nullable NSString *)url delegate:(nullable id<YJAvaterViewDelegate>)delegate;

/// 更新URL
/// @param url 完整URL
- (void)updateUrl:(nullable NSString *)url;

/// 更新这个实例的默认图
- (void)updateDefaultAvaterImgName:(NSString *)defaultImgName;

@end

NS_ASSUME_NONNULL_END
