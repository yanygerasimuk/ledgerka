//
//  YYGOperationOneAndHalfRowCell.m
//  Ledger
//
//  Created by Ян on 19.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationOneAndHalfRowCell.h"
#import "YGTools.h"

@interface YYGOperationOneAndHalfRowCell() {
    UILabel *p_source;
    UILabel *p_target;
    UILabel *p_sum;
}
@end

@implementation YYGOperationOneAndHalfRowCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Sum
        p_sum = [[UILabel alloc] initWithFrame:CGRectZero];
        p_sum.translatesAutoresizingMaskIntoConstraints = NO;
        p_sum.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:p_sum];
        
#ifdef FUNC_DEBUG
        p_sum.backgroundColor = [UIColor greenColor];
#endif
        
        [p_sum.heightAnchor constraintEqualToConstant:30.0f].active = YES;
        [p_sum.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [p_sum.widthAnchor constraintGreaterThanOrEqualToConstant:30.0f].active = YES;
        [p_sum.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15.0f].active = YES;
        
        // Source
        p_source = [[UILabel alloc] initWithFrame:CGRectZero];
        p_source.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:p_source];
      
#ifdef FUNC_DEBUG
        p_source.backgroundColor = [UIColor greenColor];
#endif
        
        [p_source.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0f].active = YES;
        [p_source.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10.0f].active = YES;
        [p_source.heightAnchor constraintEqualToConstant:30.0f].active = YES;
        [p_source.trailingAnchor constraintLessThanOrEqualToAnchor:p_sum.leadingAnchor constant:-10.0f].active = YES;
        
        // Target
        p_target = [[UILabel alloc] initWithFrame:CGRectZero];
        p_target.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:p_target];
        
#ifdef FUNC_DEBUG
        p_target.backgroundColor = [UIColor greenColor];
#endif
        
        [p_target.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0f].active = YES;
        [p_target.topAnchor constraintEqualToAnchor:p_source.bottomAnchor constant:10.0f].active = YES;
        [p_target.heightAnchor constraintEqualToConstant:30.0f].active = YES;
        [p_target.trailingAnchor constraintGreaterThanOrEqualToAnchor:p_sum.leadingAnchor constant:-10.0f].active = YES;
    }
    return self;
}

- (void)setSource:(NSString *)source {
    if(![_source isEqualToString:source]) {
        _source = source;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_source
                                              attributes:attributes];
        
        p_source.attributedText = textAttributed;
    }
}

- (void)setTarget:(NSString *)target {
    if(![_target isEqualToString:target]) {
        _target = target;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_target
                                              attributes:attributes];
        
        p_target.attributedText = textAttributed;
    }
}

- (void)setSum:(NSString *)sum {
    if(![_sum isEqualToString:sum]) {
        _sum = sum;
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                     NSForegroundColorAttributeName:[self colorFor:_type],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_sum
                                              attributes:attributes];
        
        p_sum.attributedText = textAttributed;
    }
}

- (UIColor *)colorFor:(YGOperationType)type {
    UIColor *color;
    switch(type) {
        case YGOperationTypeGiveDebt:
            color = [UIColor blueColor];
            break;
        case YGOperationTypeRepaymentDebt:
            color = [UIColor purpleColor];
            //color = [UIColor colorWithRed:30.0/255.0 green:153.0/255.0 blue:241.0/255.0 alpha:1.0f];
            break;
        case YGOperationTypeGetCredit:
            color = [UIColor orangeColor];
            break;
        case YGOperationTypeReturnCredit:
            color = [UIColor brownColor];
            break;
        default:
            return [UIColor blackColor];
    }
    return color;
}

@end
