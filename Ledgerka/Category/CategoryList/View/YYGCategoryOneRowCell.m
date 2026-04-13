//
//  YGCategoryOneRowCell.m
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryOneRowCell.h"
#import "YGTools.h"

NSString *const kCategoryOneRowCellId = @"CategoryOneRowCellId";

@interface YYGCategoryOneRowCell () {
    NSInteger _fontSizeLeftText;
    NSInteger _fontSizeRightText;
}
@end

@implementation YYGCategoryOneRowCell

@synthesize textLeft = _textLeft, textRight = _textRight, colorTextLeft = _colorTextLeft, colorTextRight = _colorTextRight;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // crutch, else cell created with default style
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        _fontSizeLeftText = [YGTools defaultFontSize];
        _fontSizeRightText = _fontSizeLeftText+2;
        
        _textLeft = @"";
        _textRight = @"";
        
        _colorTextLeft = [UIColor blackColor];
        _colorTextRight = [UIColor grayColor];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setTextLeft:(NSString *)textLeft {
    
    if(textLeft && ![_textLeft isEqualToString:textLeft]){
        _textLeft = textLeft;
        
        [self updateLeftTextAttributes];
    }
}

- (void)setTextRight:(NSString *)textRight {
    
    if(textRight && ![_textRight isEqualToString:textRight]){
        _textRight = textRight;
        [self updateRightTextAttributes];
    }
}

- (void)setColorTextLeft:(UIColor *)colorTextLeft {
    
    if(colorTextLeft && ![_colorTextLeft isEqual:colorTextLeft]){
        _colorTextLeft = colorTextLeft;
        [self updateLeftTextAttributes];
    }
}

- (void)setColorTextRight:(UIColor *)colorTextRight {

    if(colorTextRight && ![_colorTextRight isEqual:colorTextRight]){
        _colorTextRight = colorTextRight;
        [self updateRightTextAttributes];
    }
}

/**
 Update control attributed text, when property set.
 */
- (void)updateLeftTextAttributes {
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeLeftText],
                                     NSForegroundColorAttributeName:self.colorTextLeft,
                                     };
    NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.textLeft attributes:textAttributes];
    
    self.textLabel.attributedText = textAttributed;
}

- (void)updateRightTextAttributes {
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeRightText],
                                     NSForegroundColorAttributeName:self.colorTextRight,
                                     };
    NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.textRight attributes:textAttributes];
    
    self.detailTextLabel.attributedText = textAttributed;
}

- (void)setType:(YGCategoryType)type {
    _type = type;
}

@end

