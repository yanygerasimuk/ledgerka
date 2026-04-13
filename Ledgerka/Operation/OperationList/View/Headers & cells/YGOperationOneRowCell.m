//
//  YGOperationOneRowCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationOneRowCell.h"
#import "YGTools.h"

@interface YGOperationOneRowCell() {
    NSInteger _fontSizeLeftText;
    NSInteger _fontSizeRightText;
    UIColor *_colorLeftText;
    UIColor *_colorRightText;
}
@end

@implementation YGOperationOneRowCell

@synthesize leftText = _leftText, rightText = _rightText;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // crutch, else cell created with default style
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if(self) {
        
        _fontSizeLeftText = [YGTools defaultFontSize];
        _fontSizeRightText = _fontSizeLeftText;
        
        _colorLeftText = [UIColor blackColor];
        _colorRightText = [self colorForOperationType:_type];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setLeftText:(NSString *)leftText {
    
    if(leftText && ![_leftText isEqualToString:leftText]) {
        _leftText = leftText;
        self.textLabel.text = self.leftText;
        self.textLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    }
}

- (void)setRightText:(NSString *)rightText {
    
    if(rightText && ![_rightText isEqualToString:rightText]) {
        _rightText = rightText;
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeRightText],
                                         NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                         };
        NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.rightText attributes:textAttributes];
        
        self.detailTextLabel.attributedText = textAttributed;
    }
}

- (void)setType:(YGOperationType)type {
    _type = type;
}

- (UIColor *)colorForOperationType:(YGOperationType)type {
    
    UIColor *incomeColor = [UIColor colorWithRed:0/255.f green:132/255.f blue:0/255.f alpha:1.f];
    
    UIColor *expenseColor = [UIColor colorWithRed:209/255.f green:47/255.f blue:27/255.f alpha:1.f];
    
    UIColor *setDebtColor = [UIColor grayColor];
    //[UIColor colorWithRed:16/255.f green:69/255.f blue:251/255.f alpha:1.0f];
    
    switch(type) {
        case YGOperationTypeExpense: return expenseColor; //[UIColor redColor];
        case YGOperationTypeIncome: return incomeColor; //[UIColor greenColor];
        case YGOperationTypeAccountActual: return [UIColor grayColor];
        case YGOperationTypeTransfer: return [UIColor grayColor];
        case YGOperationTypeSetDebt: return setDebtColor;
            
        default: return [UIColor blackColor];
    }
}

@end
