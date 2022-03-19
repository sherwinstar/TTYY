//
//  UIPlaceHolderTextView.m
//  YouShaQi
//
//  Created by admin on 12-9-6.
//  Copyright (c) 2012年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "UIPlaceHolderTextView.h"
#import "YJUIDefine.h"
#import "CustomStringUtils.h"

@implementation UIPlaceHolderTextView
@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;
@synthesize floatTip;
@synthesize wordCount;
@synthesize placeHolderPadding;
@synthesize placeHolderTopPadding;
@synthesize placeHolderLeftPadding;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)setPlaceholderFrame:(CGRect *)frame
{
    
}

- (void)textChanged:(NSNotification *)notification
{
    if ([[self placeholder] length] == 0) {
        return;
    }
    
    if ([[self text] length] == 0) {
        [[self viewWithTag:999] setAlpha:1];
        if (self.tag == 1) {
            wordCount.text = [NSString stringWithFormat:@"字数限制：%ld", (long)100];
            [self setNeedsDisplayInRect:floatTip.frame];
        }
    } else {
        [[self viewWithTag:999] setAlpha:0];
        if (self.tag == 1) {
            int count = [CustomStringUtils countWord:[self text]];
            wordCount.text = [NSString stringWithFormat:@"字数限制：%ld", (long)(100 - count)];
            [self setNeedsDisplayInRect:floatTip.frame];
        }
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if( [[self placeholder] length] > 0 ) {
        if ( placeHolderLabel == nil ) {
            placeHolderPadding = placeHolderPadding ? placeHolderPadding : 0;
            placeHolderTopPadding = placeHolderTopPadding ? placeHolderTopPadding : 0;
            CGFloat textViewY = (placeHolderTopPadding != 0) ? placeHolderTopPadding : placeHolderPadding;
            CGFloat placeHoderX = (placeHolderLeftPadding != 0) ? placeHolderLeftPadding : placeHolderPadding;
            CGRect frame = CGRectMake(placeHoderX, textViewY, self.bounds.size.width - placeHolderPadding*2, 0);
            placeHolderLabel = [[UILabel alloc] initWithFrame:frame];
            placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            if (self.tag == 1) {
                placeHolderLabel.shadowColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4f];
                placeHolderLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            }
            [self addSubview:placeHolderLabel];
        }
        
        if (self.placeholderLineSpacing > 0) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeholder ?: @""];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:self.placeholderLineSpacing];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [placeholder length])];
            placeHolderLabel.attributedText = attributedString;
        } else {
            placeHolderLabel.text = self.placeholder;
        }
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 ) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (void)showFloatTip:(CGRect)frame
{
    if (self.tag == 1) {
        if (floatTip == nil) {
            floatTip = [[UIView alloc] initWithFrame:frame];
            floatTip.backgroundColor = Color_RGB(30, 30, 30);

            self.wordCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
            wordCount.backgroundColor = [UIColor clearColor];
            wordCount.textColor = Color_RGB(78, 78, 78);
            //        wordCount.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
            wordCount.font = [UIFont systemFontOfSize:13.0f];
            wordCount.text = @"字数限制：100";
            wordCount.shadowColor = Color_RGBA(0, 0, 0, 0.4f);
            wordCount.shadowOffset = CGSizeMake(0.0f, 1.0f);
            [floatTip addSubview:wordCount];
        }
        floatTip.hidden = NO;
        [self addSubview:floatTip];
        [self bringSubviewToFront:floatTip];
    }
}

- (void)hideFloatTip
{
    [wordCount removeFromSuperview];
    self.wordCount = nil;
    [floatTip removeFromSuperview];
    self.floatTip = nil;
}

- (CGRect)calculateFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    CGRect frame = CGRectMake(0, self.window.frame.size.height - keyboardHeight - 40 - 44, Screen_Width, 40);
    
    return frame;
}

- (void)handleKeyboardDidShow:(NSNotification *)notification
{
    CGRect frame = [self calculateFrame:notification];
    [self showFloatTip:frame];
    [self setNeedsDisplayInRect:floatTip.frame];
}

- (void)handleKeyboardWillChange:(NSNotification *)notification
{
    CGRect frame = [self calculateFrame:notification];
    floatTip.frame = frame;
    [self setNeedsDisplayInRect:floatTip.frame];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    if (floatTip) {
        [self hideFloatTip];
    }
}

@end
