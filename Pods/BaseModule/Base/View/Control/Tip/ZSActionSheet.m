//
//  ZSActionSheet.m
//  YouShaQi
//
//  Created by yun on 2017/11/14.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "ZSActionSheet.h"
#import "YJRectDefine.h"
#import "YJUIDefine.h"
#import "YJLanguageHelper.h"
#import "UIView+FrameConvenience.h"

static NSInteger const kZSSheetBtnTagBase = 201711150;
@interface ZSActionSheet()

@property (nonatomic, weak) id<ZSActionSheetDelegate> delegate;
@property (nonatomic, assign) CGFloat allHeight;
@property (nonatomic, assign) BOOL isHidingAnimation;
@property (nonatomic, strong) UIButton *backView;
@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

static ZSActionSheet *manager;

@interface ZSActionSheet ()

@property (nonatomic, assign) NSInteger tag;

@end

@implementation ZSActionSheet

- (void)dealloc {
    NSLog(@"杀掉了.....");
}

+ (instancetype)shareActionSheet {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!manager) {
        manager = [super allocWithZone:zone];
    }
    return manager;
}

- (void)showActionSheetWithDelegate:(id)localDelegate actionTitle:(NSString *)actionTitle otherButtonTitles:(NSArray<NSString *> *)titles currentSelectIndex:(NSInteger)selIndex indicatorIndexs:(NSArray<NSNumber *> *)indexs {
    [self showActionSheetWithDelegate:localDelegate actionTitle:actionTitle otherButtonTitles:titles currentSelectIndex:selIndex indicatorIndexs:indexs withTag:-1];
}

- (void)showActionSheetWithDelegate:(id)localDelegate actionTitle:(NSString *)actionTitle otherButtonTitles:(NSArray<NSString *> *)titles currentSelectIndex:(NSInteger)selIndex indicatorIndexs:(NSArray<NSNumber *> *)indexs withTag:(NSInteger)tag {
    CGFloat delay = 0;
    if (self.isHidingAnimation) {
        delay = 0.3f;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!titles.count) {
            return;
        }
        self.tag = tag;
        
        self.delegate = localDelegate;
        NSInteger count = titles.count;
        CGFloat singleH = Screen_IPadMultiply(64);
        self.allHeight = count * singleH + Screen_IPadMultiply(50) + (actionTitle.length ? 73 : 0);
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        backBtn.backgroundColor = Color_RGBA(0, 0, 0, 0);
        [backBtn addTarget:self action:@selector(hiddenSheet) forControlEvents:UIControlEventTouchUpInside];
        self.backView = backBtn;
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        self.blurView.frame = CGRectMake(Screen_IPadMultiply(10), Screen_Height, Screen_Width - Screen_IPadMultiply(20), self.allHeight);
        self.blurView.layer.masksToBounds = YES;
        self.blurView.layer.cornerRadius = Screen_IPadMultiply(8);
        self.blurView.contentView.backgroundColor = Color_RGBA(255, 255, 255, 0.7);
        
        UILabel *actionTitleLabel = nil;
        if (actionTitle.length) {
            actionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.blurView.width, 73)];
            actionTitleLabel.font = Font_Bold_IPadMul(18);
            actionTitleLabel.textColor = [UIColor blackColor];
            actionTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.blurView.contentView addSubview:actionTitleLabel];
            actionTitleLabel.text = actionTitle;
        }
        
        CGFloat actionItemStartY = CGRectGetMaxY(actionTitleLabel.frame);
        for (int i = 0; i < count; i++) {
            BOOL sel = (selIndex == i);
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(Screen_IPadMultiply(20), i * singleH + actionItemStartY, self.blurView.width - Screen_IPadMultiply(40), singleH)];
            if (selIndex == -1 && !indexs) {
                lb.textAlignment = NSTextAlignmentCenter;
            }
            lb.font = [UIFont systemFontOfSize:Screen_IPadMultiply(17.0)];
            lb.textColor = sel ? Color_Hex(0xEE4745) : Color_Hex(0x616166);
            lb.text = [YJLanguageHelper translateStr:titles[i]];
            [self.blurView.contentView addSubview:lb];
            
            for (NSNumber *numIndex in indexs) {
                if (([numIndex integerValue] == i) && (selIndex != i)) {
                    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.blurView.width - Screen_IPadMultiply(24 + 20), i * singleH + singleH / 2 - Screen_IPadMultiply(7), Screen_IPadMultiply(14), Screen_IPadMultiply(14))];
                    imgV.image = [UIImage imageNamed:@"reader_icon_more_14_14"];
                    [self.blurView.contentView addSubview:imgV];
                }
            }
            
            if (sel) {
                UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.blurView.width - Screen_IPadMultiply(24 + 20), lb.center.y-Screen_IPadMultiply(16), Screen_IPadMultiply(32), Screen_IPadMultiply(32))];
                imgV.image = [UIImage imageNamed:@"reader_def_xuance2_32_32"];
                [self.blurView.contentView addSubview:imgV];
            }
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(Screen_IPadMultiply(20), Screen_IPadMultiply((i + 1) * singleH) - 0.5 + actionItemStartY, self.blurView.width - Screen_IPadMultiply(40), 0.5)];
            line.backgroundColor = Color_Hex(0xEBEBF0);
            [self.blurView.contentView addSubview:line];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * singleH + actionItemStartY, self.blurView.width, singleH)];
            btn.tag = i + kZSSheetBtnTagBase;
            [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self.blurView.contentView addSubview:btn];
        }
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, self.allHeight - Screen_IPadMultiply(50), self.blurView.width, Screen_IPadMultiply(50));
        cancelBtn.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        cancelBtn.titleLabel.font = Font_System_IPadMul(17);
        [cancelBtn setTitle:[YJLanguageHelper translateStr:@"取 消"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:Color_Hex(0xB7B7BD) forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(hiddenSheet) forControlEvents:UIControlEventTouchUpInside];
        [self.blurView.contentView addSubview:cancelBtn];
        
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        [window addSubview:self.backView];
        [window addSubview:self.blurView];
        
        [self startAnimaition];
    });
}

//举报弹框
- (void)showActionSheetTitle:(NSString *)title otherButtonTitles:(NSArray<NSString *> *)titles curretVC:(UIViewController *)viewController selectIndexBlock:(void (^)(NSInteger index))block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i <[titles count]; i++) {
        NSString *title = [titles objectAtIndex:i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[YJLanguageHelper translateStr:title] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            block(i);
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:[YJLanguageHelper translateStr:@"取消"] style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancle];
    if ([alert respondsToSelector:@selector(popoverPresentationController)]) {
        alert.popoverPresentationController.sourceView = viewController.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(0, Screen_Height- titles.count*60, Screen_Width, Screen_Height);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)clickBtn:(UIButton *)btn {
    [self hiddenSheet];
    if ([_delegate respondsToSelector:@selector(actionSheet:didClickButton:index:withTag:)]) {
        [_delegate actionSheet:self didClickButton:btn index:btn.tag - kZSSheetBtnTagBase withTag:self.tag];
    }
}

- (void)selecteClickedButton:(UIButton *)btn {
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(btn.width - Screen_IPadMultiply(24 + 20), 0, Screen_IPadMultiply(32), Screen_IPadMultiply(32))];
    imgV.image = [UIImage imageNamed:@"reader_def_xuance2_32_32"];
    [btn addSubview:imgV];
}

- (void)startAnimaition {
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.backgroundColor = Color_RGBA(0, 0, 0, 0.4);
        self.blurView.y = Screen_Height - self.allHeight - Screen_IPadMultiply(10);
    }];
}

- (void)hiddenSheet {
    self.isHidingAnimation = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.backgroundColor = Color_RGBA(0, 0, 0, 0);
        self.blurView.y = Screen_Height;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.blurView removeFromSuperview];
        self.isHidingAnimation = NO;
    }];
}

@end
