//
//  UIPlaceHolderTextView.h
//  YouShaQi
//
//  Created by admin on 12-9-6.
//  Copyright (c) 2012年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView{

    NSString *placeholder;
    UIColor *placeholderColor;
@private
    UILabel *placeHolderLabel;

}
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) NSInteger placeholderLineSpacing;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIView *floatTip;
@property (nonatomic, strong) UILabel *wordCount;
@property (nonatomic, assign) NSInteger placeHolderPadding;
@property (nonatomic, assign) NSInteger placeHolderTopPadding;//UI改版创建书单用
@property (nonatomic, assign) NSInteger placeHolderLeftPadding;//UI改版创建书单用
- (void)textChanged:(NSNotification*)notification;
@end
