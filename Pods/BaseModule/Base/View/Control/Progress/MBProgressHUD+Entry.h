//
//  MBProgressHUD+Entry.h
//  YouShaQi
//
//  Created by Admin on 2020/6/2.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

/*
 progress的统一：
 1、不能使用 UIActivityIndicatorView（除了小面积的那种）
 2、toast 都使用 ViewUtils 里的
 3、progress 分为四种：
     （1）默认progress: 不可取消+没有文字提示+白色背景+追书logo样式
     （2）内购progress：可以取消+有文字提示+黑色背景+没有追书logo样式
     （3）阅读器初始化progress：不可取消+可以点击+没有文字提示+白色背景+追书logo样式
     （4）书籍详情页添加书籍progress：不可取消+没有文字提示+白色背景+成功icon样式
 */

@protocol YJProgressOwnerProtocol <MBProgressHUDDelegate>

@optional

// oc 需要 @synthesize progress = _progress;
@property (nonatomic, strong, readwrite, nullable) UIView *progress;

// （只有书城初始化时需要）默认 progress 会和父视图同大小，目前只有书城需要定制，因为书城前后两个 progress 的父视图大小不一样，导致两个 progress 一上一下，有跳跃的问题，只能指定其中一个 progress 的大小跟另一个一样，目前其他地方不需要实现这个方法
- (CGRect)progressFrame;

// （只有阅读器初始化时需要）由于 progress 没有取消按钮了，再加上阅读器不能侧滑返回，所以阅读器初始化时的 progress 可以响应点击手势，并调用代理的 hudWasClicked，阅读器的菜单就展示了，此时的菜单只有返回按钮可以点击
- (void)hudWasClicked;

// 是否是夜间模式，默认值是 NO
- (BOOL)isNightTheme;

@end

@interface MBProgressHUD (Entry)

+ (UIView *)progressDefaultSuperView;

// 立即隐藏
+ (void)hideProgressOwned:(id<YJProgressOwnerProtocol>)owner;

// 指定时间后，隐藏
+ (void)hideProgressOwned:(id<YJProgressOwnerProtocol>)owner duration:(CGFloat)duration;
+ (void)hideLaterProgressOwned:(id<YJProgressOwnerProtocol>)owner;

// 默认progress
+ (void)showProgressInView:(UIView *)superView
                     owner:(id<YJProgressOwnerProtocol>)owner;
// 阅读器初始化阶段的progress：可以响应点击，在夜间模式下，阅读器的progress的UI与其他位置的不同
+ (void)showReaderInitialProgressInView:(UIView *)superView
                           owned:(id<YJProgressOwnerProtocol>)owner;
// 阅读器非初始化阶段的progress：不可以响应点击，在夜间模式下，阅读器的progress的UI与其他位置的不同
+ (void)showReaderProgressInView:(UIView *)superView
                           owned:(id<YJProgressOwnerProtocol>)owner;
// 内购progress
+ (void)showIapProgressMsg:(nullable NSString *)msg
                     owner:(id<YJProgressOwnerProtocol>)owner;
// 内购progress
+ (void)updateIapProgressInOwner:(id<YJProgressOwnerProtocol>)owner
                             msg:(nullable NSString *)msg;
// 书籍详情页添加书籍progress
+ (void)showProgressInView:(UIView *)superView
                     owner:(id<YJProgressOwnerProtocol>)owner
                       msg:(NSString *)msg
                 imageName:(NSString *)imageName;
// 书籍详情页添加书籍progress
+ (void)updateProgressOwned:(id<YJProgressOwnerProtocol>)owner
                        msg:(nullable NSString *)msg
                  imageName:(NSString *)imageName;

@end

/*
 对于大部分使用场景，都是在类的实例方法中使用MBProgress的，实例去持有progress就可以了
 但对于类似于 YJSiriIntentHelper，由于没有实例，所以没有就没有owner对象去实现YJProgressOwnerProtocol
 去声明一个progress的property了
 这种情况使用这个延展中的方法
 方法实现得不全，有需要再添加
 */
@interface MBProgressHUD (ClassEntry)

// 找不到实例去充当 owner 了，才会用这些方法

+ (void)hideProgress:(MBProgressHUD * _Nonnull __strong *_Nonnull)hud;

+ (void)showProgressInView:(UIView *)superView completion:(void(^)(MBProgressHUD *))completion;

@end

NS_ASSUME_NONNULL_END
