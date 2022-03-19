//
//  DarkModeView.h
//  KingReader
//
//  Created by wangbc on 15/10/14.
//  Copyright © 2015年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DarkModeView : UIView

+ (void)startDarkModeViewWithCheckBlock:(BOOL(^)())checkBlock;
+ (void)showDarkModeViewIfNeeded;
+ (void)tempHideDarkModeView;

@end
