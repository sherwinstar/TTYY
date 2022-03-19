//
//  YJTableViewCell.m
//  YouShaQi
//
//  Created by tjj on 2018/3/7.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "YJTableViewCell.h"
#import "YJUIDefine.h"

@implementation YJTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSelectedView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSelectedView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSelectedView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupSelectedView];
}

- (void)setupSelectedView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = Color_HexA(0xF0F0F5, 0.39);
}

@end
