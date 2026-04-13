//
//  YGOperationTwoRowCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationTwoRowCell.h"
#import "YGTools.h"

@interface YGOperationTwoRowCell() {
    CGFloat _width;
    NSInteger _fontSizeText;
    NSInteger _fontSizeDetailText;
    UIColor *_colorText;
    UIColor *_colorDetailText;
}
@property (strong, nonatomic) UILabel *labelFirstRowText;
@property (strong, nonatomic) UILabel *labelFirstRowDetailText;
@property (strong, nonatomic) UILabel *labelSecondRowText;
@property (strong, nonatomic) UILabel *labelSecondRowDetailText;
@end

@implementation YGOperationTwoRowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        
        _width = [YGTools deviceScreenWidth];
        _fontSizeText = [YGTools defaultFontSize];
        _fontSizeDetailText = _fontSizeText;
        
        _colorText = [UIColor blackColor];
        _colorDetailText = [self colorForOperationType:_type];
        
        _firstRowText = @"";
        _firstRowDetailText = @"";
        _secondRowText = @"";
        _secondRowDetailText = @"";
        
        // First row text
        self.labelFirstRowText = [[UILabel alloc] initWithFrame:[self rectFirstRowLabel]];
        self.labelFirstRowText.textAlignment = NSTextAlignmentLeft;
        self.labelFirstRowText.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.labelFirstRowText];
        
        // First row detail text
        self.labelFirstRowDetailText = [[UILabel alloc] initWithFrame:[self rectFirstRowLabel]];
        self.labelFirstRowDetailText.textAlignment = NSTextAlignmentRight;
        self.labelFirstRowText.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.labelFirstRowDetailText];
        
        // Second row text
        self.labelSecondRowText = [[UILabel alloc] initWithFrame:[self rectSecondRowLabel]];
        self.labelSecondRowText.textAlignment = NSTextAlignmentLeft;
        self.labelSecondRowText.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.labelSecondRowText];
        
        // Second row detail text
        self.labelSecondRowDetailText = [[UILabel alloc] initWithFrame:[self rectSecondRowLabel]];
        self.labelSecondRowDetailText.textAlignment = NSTextAlignmentRight;
        self.labelSecondRowText.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.labelSecondRowDetailText];
         
    }
    return self;
}

/**
 Use the same rectangle for leftText and rightDetailText labels.
 
 */
- (CGRect)rectFirstRowLabel {
    
    static CGRect rectFirstRowLabel;
    
    if(rectFirstRowLabel.size.width == 0) {
        if(_width <= 320.f)
            rectFirstRowLabel = CGRectMake(16, 4, 288, 36); // (16, 4, 160, 36) - (180, 4, 125, 36)
        else if(_width > 320.f && _width <= 375.f)
            rectFirstRowLabel = CGRectMake(16, 4, 343, 40); // (16, 4, 187, 40) - (210, 6, 150, 40)
        else if(_width > 375.f && _width <= 414.f)
            rectFirstRowLabel = CGRectMake(20, 6, 374, 42); // (20, 6, 207, 42) - (230, 4, 165, 42)
        else
            rectFirstRowLabel = CGRectMake(20, 6, 374, 42); // (20, 6, 207, 42) - (230, 4, 165, 42)
    }
    return rectFirstRowLabel;
}

- (CGRect)rectSecondRowLabel {
    
    static CGRect rectSecondRowLabel;
    
    if(rectSecondRowLabel.size.width == 0) {
        if(_width <= 320.f)
            rectSecondRowLabel = CGRectMake(16, 40, 288, 36); // x + width = 160
        else if(_width > 320.f && _width <= 375.f)
            rectSecondRowLabel = CGRectMake(16, 42, 343, 40); // x + width = 187
        else if(_width > 375.f && _width <= 414.f)
            rectSecondRowLabel = CGRectMake(20, 48, 374, 42); // x + width = 207
        else
            rectSecondRowLabel = CGRectMake(20, 48, 374, 42); // x + width = 207
    }
    return rectSecondRowLabel;
}


- (void)setFirstRowText:(NSString *)firstRowText {
    
    if(firstRowText && ![_firstRowText isEqualToString:firstRowText]) {
        _firstRowText = firstRowText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_firstRowText
                                              attributes:attributes];
        
        self.labelFirstRowText.attributedText = textAttributed;
    }
}

- (void)setFirstRowDetailText:(NSString *)firstRowDetailText {
    
    if(firstRowDetailText && ![_firstRowDetailText isEqualToString:firstRowDetailText]) {
        _firstRowDetailText = firstRowDetailText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeDetailText],
                                     NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_firstRowDetailText
                                              attributes:attributes];
        
        self.labelFirstRowDetailText.attributedText = textAttributed;
    }
    
}

- (void)setSecondRowText:(NSString *)secondRowText {
    
    if(secondRowText && ![_secondRowText isEqualToString:secondRowText]) {
        _secondRowText = secondRowText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_secondRowText
                                              attributes:attributes];
        
        self.labelSecondRowText.attributedText = textAttributed;
    }
}

- (void)setSecondRowDetailText:(NSString *)secondRowDetailText {
    
    if(secondRowDetailText && ![_secondRowDetailText isEqualToString:secondRowDetailText]) {
        _secondRowDetailText = secondRowDetailText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeDetailText],
                                     NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_secondRowDetailText
                                              attributes:attributes];
        
        self.labelSecondRowDetailText.attributedText = textAttributed;
    }
}

- (void)setType:(YGOperationType)type {
    _type = type;
}

- (UIColor *)colorForOperationType:(YGOperationType)type {
    switch(type) {
        case YGOperationTypeExpense: return [YGTools colorRed];
        case YGOperationTypeIncome: return [YGTools colorGreen];
        case YGOperationTypeAccountActual: return [UIColor grayColor];
        case YGOperationTypeTransfer: return [UIColor grayColor];
        default: return [UIColor blackColor];
    }
}

@end
