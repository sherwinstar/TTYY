//
//  MSLabel.m
//  Miso
//
//  Created by Joshua Wu on 11/15/11.
//  Copyright (c) 2011 Miso. All rights reserved.
//

#import "MSLabel.h"
#import "CustomSizeUtils.h"
#import <CoreGraphics/CoreGraphics.h>

// small buffer to allow for characters like g,y etc 
static const int kAlignmentBuffer = 5;

@interface MSLabel ()

- (void)setup;
- (NSArray *)stringsFromText:(NSString *)string;

- (NSMutableArray *)stringsWithWordsWrappedFromArray:(NSArray *)strings;
- (NSMutableArray *)arrayOfCharactersInString:(NSString *)string;
- (NSString *)lastWordInString:(NSString *)string;


@property (nonatomic, assign) int drawX;

@end

@implementation MSLabel

@synthesize lineHeight = _lineHeight;
@synthesize verticalAlignment = _verticalAlignment;
@synthesize drawX;

#pragma mark - Initilisation

- (id)initWithFrame:(CGRect)frame {
    
    
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    
    return self;
}


#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect  {
    NSArray *slicedStrings = [self stringsFromText:self.text];
    if (self.highlighted && self.highlightedTextColor) {
        [self.highlightedTextColor set]; 
    } else {
        [self.textColor set];   
    }
    
    int numLines = slicedStrings.count;
    if (numLines > self.numberOfLines && self.numberOfLines != 0) {
        numLines = self.numberOfLines;
    }
    
    int drawY = (self.frame.size.height / 2 - (_lineHeight * numLines) / 2) - kAlignmentBuffer;
    
    for (int i = 0; i < numLines; i++) {        
        
        NSString *line = [slicedStrings objectAtIndex:i];
        
        // calculate draw Y based on alignment
        switch (_verticalAlignment) {
            case MSLabelVerticalAlignmentTop:
            {
                drawY = i * _lineHeight;
            }
                break;
            case MSLabelVerticalAlignmentMiddle:
            {
                if(i > 0) {
                    drawY += _lineHeight;            
                }
            }
                break;
            case MSLabelVerticalAlignmentBottom:
            {
                drawY = (self.frame.size.height - _lineHeight * numLines) + ((i  * _lineHeight) - kAlignmentBuffer);
            }
                break;
            default:
            {
                if(i > 0) {
                    drawY = i * _lineHeight;
                }
            }
                break;
        }
        
        // calculate draw X based on textAlignmentment
        
        if (self.textAlignment == NSTextAlignmentCenter) {
//            drawX = floorf((self.frame.size.width - [line sizeWithFont:self.font].width) / 2);
            drawX = floorf((self.frame.size.width - [CustomSizeUtils simpleSizeWithStr:line font:self.font].width) / 2);
        } else if (self.textAlignment == NSTextAlignmentRight) {
//            drawX = (self.frame.size.width - [line sizeWithFont:self.font].width);
            drawX = (self.frame.size.width - [CustomSizeUtils simpleSizeWithStr:line font:self.font].width);
        }
        
        drawX = drawX < 0 ? 0 : drawX;
        
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, 0, self.shadowColor.CGColor);
        
        UIColor *tmpTextColor;
        if (self.highlighted && self.highlightedTextColor) {
            tmpTextColor = self.highlightedTextColor;
        } else {
            tmpTextColor = self.textColor;
        }
        NSDictionary *attributeDic = @{NSFontAttributeName: self.font,
                                       NSForegroundColorAttributeName: tmpTextColor};
        
        [line drawAtPoint:CGPointMake(drawX, drawY) withAttributes:attributeDic];
    }
}


#pragma mark - Properties

- (void)setLineHeight:(int)lineHeight {
    if (_lineHeight == lineHeight) 
    { 
        return; 
    }
    
    _lineHeight = lineHeight;
    [self setNeedsDisplay];
}


#pragma mark - Private Methods

- (void)setup {
    _lineHeight = 12;
    _verticalAlignment = MSLabelVerticalAlignmentMiddle;
}

- (NSArray *)stringsFromText:(NSString *)string {
    NSMutableArray *characterArray = [self arrayOfCharactersInString:string];
    NSMutableArray *slicedString = [NSMutableArray array];
    
    while (characterArray.count != 0) {
        NSString *line = @"";
        NSMutableIndexSet *charsToRemove = [NSMutableIndexSet indexSet];
        
        for (int i = 0; i < [characterArray count]; i++) {
            NSString *character = [characterArray objectAtIndex:i];
            CGFloat stringWidth = [CustomSizeUtils simpleSizeWithStr:[line stringByAppendingFormat:@"%@", character] font:self.font].width;
            
            // shrink font to fit text as best as we can
//            if(stringWidth > (self.frame.size.width - 10)) {
//                CGFloat fontSize = self.font.pointSize;
//                
//                while(stringWidth > (self.frame.size.width - 10) && fontSize >= self.minimumFontSize) {
//                    self.font = [UIFont fontWithName:self.font.fontName size:fontSize--];
//                    _lineHeight = self.font.pointSize;
//                    stringWidth = [[line stringByAppendingFormat:@"%@", character] sizeWithFont:self.font].width;
//                }
//            }

            if (![character isEqualToString:@"\n"]) {
                if (stringWidth <= self.frame.size.width) {
                    line = [line stringByAppendingFormat:@"%@", character];
                    [charsToRemove addIndex:i];
                } else {
                    if (line.length == 0) {
                        line = [line stringByAppendingFormat:@"%@", character];
                        [charsToRemove addIndex:i];
                    }
                    break;
                }
            } else {
                [charsToRemove addIndex:i];
                break;
            }
        }
        
//        [slicedString addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [slicedString addObject:line];
        [characterArray removeObjectsAtIndexes:charsToRemove];
    }
    
    if (self.lineBreakMode == NSLineBreakByWordWrapping) {
        slicedString = [self stringsWithWordsWrappedFromArray:slicedString];
    }    
    
    return slicedString;
}

- (NSMutableArray *)stringsWithWordsWrappedFromArray:(NSArray *)strings {
    NSMutableArray *newStrings = [NSMutableArray arrayWithArray:strings];
    for (int i = 0; i < strings.count; i++) {
        if(i == 0) { continue; }
        NSString *lastWord = [self lastWordInString:[strings objectAtIndex:i - 1]];
        
        // Fix word wrapping
        if(lastWord.length > 0) {
            NSString *lastString = [newStrings objectAtIndex:i - 1];
            NSString *updatedString = [lastString substringToIndex:lastString.length - (lastWord.length + 1)];
            [newStrings replaceObjectAtIndex:i-1 withObject:updatedString];
            NSString *currentString = [newStrings objectAtIndex:i];
            currentString = [NSString stringWithFormat:@"%@%@",lastWord,currentString];
            [newStrings replaceObjectAtIndex:i withObject:currentString];
        }
    }
    
    if (newStrings.count > self.numberOfLines && self.numberOfLines != 0) {
        NSString *line = [newStrings objectAtIndex:(self.numberOfLines - 1)];
        line = [line stringByReplacingCharactersInRange:NSMakeRange(line.length - 3, 3) withString:@"..."];
        [newStrings removeObjectAtIndex:(self.numberOfLines - 1)];
        line = line ? line : @"";
        [newStrings insertObject:line atIndex:(self.numberOfLines - 1)];
    }
    
    return newStrings;
}

- (NSString *)lastWordInString:(NSString *)string {
    NSString *lastWord;
    
    // Check for whole words
     NSArray *wordArray = [string componentsSeparatedByString:@" "];
    lastWord = wordArray.count > 1 ? lastWord = [wordArray lastObject] : @"";
    
    return lastWord;
}

- (NSMutableArray *)arrayOfCharactersInString:(NSString *)string {
    NSRange theRange = {0, 1};
    
    NSMutableArray *stringsArray  = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [string length]; i++) {
        theRange.location = i;
        [stringsArray addObject:[string substringWithRange:theRange]];
    }
    
    return stringsArray;
}

//计算Label大小
+ (CGRect)calculateLableFrame:(MSLabel *)label
{
    [label sizeToFit];
    CGRect calculateFrame = label.frame;
    CGFloat numberOfLines = floor(calculateFrame.size.height / label.font.lineHeight);
    CGFloat limitedLines = label.numberOfLines;
    CGFloat finalNumberOfLines = limitedLines == 0 ? numberOfLines : MIN(limitedLines, numberOfLines);
    calculateFrame.size.height = finalNumberOfLines * label.lineHeight + 2;
    
    return calculateFrame;
}

@end
