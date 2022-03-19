//
//  ZSActionSheet.h
//  YouShaQi
//
//  Created by yun on 2017/11/14.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ZSShareActionSheet [ZSActionSheet shareActionSheet]

@class ZSActionSheet;

@protocol ZSActionSheetDelegate <NSObject>

/**
 类似于actionSheet

 @param actionSheet actionSheet回调
 @param btn 当前点击的按钮，可以用来自定制点击后的效果
 @param buttonIndex 当前点击按钮的index，从0开始
 */
- (void)actionSheet:(ZSActionSheet *)actionSheet didClickButton:(UIButton *)btn index:(NSInteger)buttonIndex withTag:(NSInteger)tag;

@end

@interface ZSActionSheet : NSObject

+ (instancetype)shareActionSheet;

- (void)showActionSheetWithDelegate:(id)delegate actionTitle:(NSString *)title otherButtonTitles:(NSArray<NSString *> *)titles currentSelectIndex:(NSInteger)selIndex indicatorIndexs:(NSArray<NSNumber *> *)indexs;
/**
 弹出追书的action sheet

 @param delegate 点击事件的代理
 @param titles 选项，传入字符串数组
 @param selIndex 当前默认选中的index,如果没有请传入 -1
 @param indexs 需要跳转：视图上有 > 标记的index数组
 */
- (void)showActionSheetWithDelegate:(id)delegate actionTitle:(NSString *)title otherButtonTitles:(NSArray<NSString *> *)titles currentSelectIndex:(NSInteger)selIndex indicatorIndexs:(NSArray<NSNumber *> *)indexs withTag:(NSInteger)tag;


//举报弹框
- (void)showActionSheetTitle:(NSString *)title otherButtonTitles:(NSArray<NSString *> *)titles curretVC:(UIViewController *)viewController selectIndexBlock:(void (^)(NSInteger index))block;

@end
