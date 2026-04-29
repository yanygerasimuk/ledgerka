//
//  YYGDesignSystem.m
//  Ledger
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGDesignSystem.h"
//#import "YYGOptions.h"

@interface YYGDesignSystem()

//@property (nonatomic, strong) id<YYGOptionable> options;

@end

@implementation YYGDesignSystem

// TODO: убрать по мере перехода на конструктор экземпляра
+ (YYGDesignSystem *)shared
{
    static YYGDesignSystem *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        YYGOptions *options = [YYGOptions new];
//        sharedInstance = [[YYGDesignSystem alloc] initWithOptions:options];
        shared = [YYGDesignSystem new];
    });
    return shared;
}

//- (instancetype)initWithOptions:(id<YYGOptionable>)options
//{
//    self = [super init];
//    if (self)
//    {
//        _options = options;
//    }
//    return self;
//}

- (UIColor *)colorContentPrimary
{
    return [UIColor colorNamed:@"contentPrimary"];
}

- (UIColor *)colorContentSecondary
{
    return [UIColor colorNamed:@"contentSecondary"];
}

- (UIColor *)colorSystemWarning
{
    return [UIColor colorNamed:@"systemWarning"];
}

- (UIColor *)colorBordersDefault
{
    return [UIColor colorNamed:@"bordersDefault"];
}

- (UIColor *)colorCallToActionDefault
{
    return [UIColor colorNamed:@"callToActionDefault"];
}

- (UIColor *)colorBackgroundSystem
{
    return [UIColor colorNamed:@"backgroundSystem"];
}

- (UIColor *)colorBackgroundPrimary
{
    return [UIColor colorNamed:@"backgroundPrimary"];
}

- (UIColor *)colorBackgroundSecondary
{
    return [UIColor colorNamed:@"backgroundSecondary"];
}

- (UIColor *)colorBackgroundOcean
{
    return [UIColor colorNamed:@"backgroundOcean"];
}

- (UIColor *)colorBackgroundIsland
{
    return [UIColor colorNamed:@"backgroundIsland"];
}

- (UIColor *)colorTextPrimary
{
    return [UIColor colorNamed:@"textPrimary"];
}

- (UIColor *)colorTextSecondary
{
    return [UIColor colorNamed:@"textSecondary"];
}

- (UIColor *)colorTextMint
{
    return [UIColor colorNamed:@"textMint"];
}


#pragma mark - Fonts

- (UIFont *)fontHeadMed
{
    return [UIFont systemFontOfSize:32 weight:UIFontWeightMedium];
}

- (UIFont *)fontTitleMed
{
    return [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
}

- (UIFont *)fontBodyMMed
{
    return [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
}

- (UIFont *)fontBodyMReg
{
    return [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
}

- (UIFont *)fontBodySReg
{
    return [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
}

- (UIFont *)fontCaption
{
    return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
}

@end
