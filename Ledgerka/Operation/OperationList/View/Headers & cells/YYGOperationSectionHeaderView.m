//
//  YYGOperationSectionHeaderView.m
//  Ledger
//
//  Created by Ян on 25/09/2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationSectionHeaderView.h"
#import "YGOperationSection.h"
#import "YGTools.h"

@implementation YYGOperationSectionHeaderView

- (instancetype) initWithTitle:(NSString *)title {
    
    CGFloat width = [YGTools deviceScreenWidth];
    CGFloat height = [YYGOperationSectionHeaderView height];
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, width, height)];
    if(self) {
        
        self.backgroundColor = [UIColor whiteColor]; //clearColor
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, width, height)];
        
        headerLabel.backgroundColor = [UIColor colorWithRed:(float)239/255 green:(float)239/255 blue:(float)244/255 alpha:1.0f];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = title;
        
        [self addSubview:headerLabel];
    }
    return self;
}

+ (CGFloat)height {
    static CGFloat height = 0.f;
    if(height == 0.f) {
        CGFloat width = [YGTools deviceScreenWidth];
        if(width <= 320.f)
            height = 30.f;
        else if(width > 320.f && width <= 375.f)
            height = 34.f;
        else if(width > 375.f && width <= 414.f)
            height = 38.f;
        else
            height = 40.f;
    }
    return height;
}

@end
