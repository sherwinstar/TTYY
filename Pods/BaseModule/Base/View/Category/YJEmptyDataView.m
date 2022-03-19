//
//  YJEmptyDataView.m
//  YouShaQi
//
//  Created by Beginner on 2018/3/6.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "YJEmptyDataView.h"
#import "NSString+YJ.h"
#import <Masonry/Masonry.h>
#import "YJUIDefine.h"
#import "CustomStringUtils.h"
#import "YJLanguageHelper.h"
#import "BaseModule/BaseModule-Swift.h"

#if TARGET_ZSSQ
static NSString *kEmptyImgName = @"zs_nodata_default";
static NSString *kNetworkImgName = @"zs_nodata_network";
#else
static NSString *kEmptyImgName = @"nodata_empty_new";
static NSString *kNetworkImgName = @"nodata_network";
#endif

typedef void(^EmptyBlock)();

@interface YJEmptyViewModel : NSObject

// 题目
@property (nonatomic, strong) NSString *titleImgName;

// 文字副标题
@property (nonatomic, strong) NSString *tipMsg;
@property (nonatomic, strong) UIFont *tipLabelFont;
@property (nonatomic, strong) UIColor *tipColor;
// 图片副标题
@property (nonatomic, strong) NSString *tipImgName;

// 按钮
@property (nonatomic, strong) NSString *btnTitle;
@property (nonatomic, strong) UIColor *btnBgColor;
@property (nonatomic, strong) UIColor *btnTitleColor;
@property (nonatomic, strong) UIColor *btnBorderColor;
@property (nonatomic, assign) CGFloat btnBorderWidth;
@property (nonatomic, strong) UIFont *btnFont;

+ (instancetype)defaultNetworkModel;

+ (instancetype)defaultEmptyModel;

@end

@implementation YJEmptyViewModel

/*
 追书：
 网络错误：题目图+文字副标题+按钮
 空白页：题目图+文字副标题+按钮
 饭团：
 网络错误：题目图+图片副标题+按钮
 空白页：大部分情况下是 题目图+文字副标题，少部分情况下是 题目图+按钮
 为了大部分情况下设置方便，饭团的空白页默认配置成 题目图+文字副标题（在 UIScrollView+EmptyData 中完成）
 */

// 网络错误
+ (instancetype)defaultNetworkModel {
    YJEmptyViewModel *model = [[YJEmptyViewModel alloc] init];

#if TARGET_ZSSQ
    // 追书
    model.titleImgName = @"zs_nodata_network";

    model.tipLabelFont = Font_System_IPadMul(15);
    model.tipMsg = @"咦，怎么没网了...";
    model.tipColor = Color_Hex(0xD8D8D8);
    model.tipImgName = nil; // 图片副标题

    model.btnTitle = nil;
    model.btnBgColor = Color_White;
    model.btnTitleColor = Color_ThemeRed;
    model.btnBorderColor = Color_ThemeRed;
    model.btnBorderWidth = 1;
    model.btnFont = Font_System_IPadMul(15);
#else
    
    // 饭团
    model.titleImgName = @"nodata_network";

    model.tipLabelFont = nil;
    model.tipMsg = nil;
    model.tipColor = Color_Hex(0xDADAE9);
    model.tipImgName = @"network_error_title"; // 图片副标题

    model.btnTitle = @"刷新";
    model.btnBgColor = Color_ThemeYellow;
    model.btnTitleColor = Color_Hex(0x8F4D00);
    model.btnBorderColor = nil;
    model.btnBorderWidth = 0;
    model.btnFont = Font_Medium(18);
#endif
    return model;
}

+ (instancetype)defaultEmptyModel {
    YJEmptyViewModel *model = [[YJEmptyViewModel alloc] init];
    
#if TARGET_ZSSQ
    // 追书
    model.titleImgName = @"zs_nodata_default";
    
    model.tipLabelFont = Font_System_IPadMul(15);
    model.tipMsg = @"这里什么都没有";
    model.tipColor = Color_Hex(0xD8D8D8);
    model.tipImgName = nil; // 图片副标题
    
    model.btnTitle = nil;
    model.btnBgColor = Color_White;
    model.btnTitleColor = Color_ThemeRed;
    model.btnBorderColor = Color_ThemeRed;
    model.btnBorderWidth = 1;
    model.btnFont = Font_System_IPadMul(15);
#else
    
    // 饭团
    model.titleImgName = @"nodata_empty_new";
    
    model.tipLabelFont = Font_Medium(18); // 饭团的空白页有两种：题目+文字副标题/题目+按钮
    model.tipMsg = nil;
    model.tipColor = Color_Hex(0xDADAE9);
    model.tipImgName = nil;
    
    model.btnTitle = nil;
    model.btnBgColor = Color_ThemeYellow;
    model.btnTitleColor = [UIColor blackColor];
    model.btnBorderColor = nil;
    model.btnBorderWidth = 0;
    model.btnFont = Font_Medium(18);
#endif
    return model;
}

@end

@interface YJEmptyDataView ()

@property(nonatomic, strong) YJEmptyViewModel *viewModel;

@property(nonatomic, assign) YJEmptyDataType type;

@property(nonatomic, strong) UIImageView *titleImgView; // 主要图片，相当于题目
@property(nonatomic, strong) UIImageView *tipImgView; // 提示图片，相当于副标题，tipImgView 和 tipLabel 只会同时显示一个
@property(nonatomic, strong) UILabel *tipLabel; // 提示label，相当于副标题，tipImgView 和 tipLabel 只会同时显示一个
@property(nonatomic, strong) UIButton *actionButton; // 按钮
@property(nonatomic, strong) UIView *contentView; // 为了居中显示

@property(nonatomic, copy) void(^actionBlock)(void);

@end

@implementation YJEmptyDataView

- (instancetype)initWithFrame:(CGRect)frame type:(YJEmptyDataType)type tipMsg:(NSString *)tipMsg btnTitle:(NSString *)btnTitle actionBlock:(void(^)())actionBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.viewModel = [self viewModelFromType:type];
        if (tipMsg != nil) {
            self.viewModel.tipMsg = tipMsg;
        }
        if (btnTitle != nil) {
            self.viewModel.btnTitle = btnTitle;
        }
        if (actionBlock != nil) {
            self.actionBlock = actionBlock;
        }
        [self createView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(YJEmptyDataType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.viewModel = [self viewModelFromType:type];
        [self createView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self.actionButton) {
        return hit;
    }
    return nil;
}

- (YJEmptyViewModel *)viewModelFromType:(YJEmptyDataType)type {
    if (type == YJEmptyDataTypeDefault) {
        return [YJEmptyViewModel defaultEmptyModel];
    } else {
        return [YJEmptyViewModel defaultNetworkModel];
    }
}

- (void)createView {
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    // titleImgView 是必定会有的
    self.titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.viewModel.titleImgName]];
    [self.contentView addSubview:self.titleImgView];
    [self.titleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView);
    }];
    
    UIView *centerView = nil;
    // 根据 tipMsg/tipImgName 决定是否展示
    if (self.viewModel.tipMsg != nil) {
        self.tipLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.tipLabel];
        self.tipLabel.font = self.viewModel.tipLabelFont;
        self.tipLabel.textColor = self.viewModel.tipColor;
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.numberOfLines = 2;
        self.tipLabel.text = GlobalTranlateStr(self.viewModel.tipMsg);
        centerView = self.tipLabel;
    } else if (self.viewModel.tipImgName != nil) {
        self.tipImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.viewModel.tipImgName]];
        [self.contentView addSubview:self.tipImgView];
        centerView = self.tipImgView;
    }
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.titleImgView.mas_bottom).mas_offset(Screen_IPadMultiply(24));
        make.left.greaterThanOrEqualTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView);
    }];
    
    // 根据 btnTitle 决定是否展示
    if (self.viewModel.btnTitle != nil) {
        self.actionButton = [[UIButton alloc] init];
        [self.contentView addSubview:self.actionButton];
        self.actionButton.layer.cornerRadius = Screen_IPadMultiply(20);
        self.actionButton.layer.borderColor = self.viewModel.btnTitleColor.CGColor;
        self.actionButton.layer.borderWidth = self.viewModel.btnBorderWidth;
        [self.actionButton setTitleColor:self.viewModel.btnTitleColor forState:UIControlStateNormal];
        self.actionButton.backgroundColor = self.viewModel.btnBgColor;
        self.actionButton.titleLabel.font = self.viewModel.btnFont;
        [self.actionButton setTitle:self.viewModel.btnTitle forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(handleActionBtn) forControlEvents:UIControlEventTouchUpInside];
#if TARGET_ZSSQ
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
#endif
    }
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        // 水平居中，左右边
        make.centerX.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView);
        // 距离上一个视图的高度
        BOOL hasCenterView = centerView != nil;
        UIView *lastView = hasCenterView ? centerView : self.titleImgView;
        CGFloat topMargin = Screen_IPadMultiply(hasCenterView ? 16 : 40);
        make.top.equalTo(lastView.mas_bottom).mas_offset(topMargin);
        // 固定高度
        make.height.mas_equalTo(Screen_IPadMultiply(40));
#if TARGET_FTZS
        make.width.mas_equalTo(Screen_IPadMultiply(163));
#endif
    }];
    // 确定底部间距
    UIView *bottomView = self.actionButton;
    if (bottomView == nil) {
        bottomView = self.tipLabel;
    }
    if (bottomView == nil) {
        bottomView = centerView;
    }
    if (bottomView == nil) {
        bottomView = self.titleImgView;
    }
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)handleActionBtn {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)updateTipMsg:(NSString *)tipMsg {
    self.viewModel.tipMsg = tipMsg;
    self.tipLabel.text = GlobalTranlateStr(tipMsg);
}

@end
