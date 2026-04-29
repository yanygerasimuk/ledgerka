//
//  YYGDesignSystem+Typography.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGDesignSystem+Typography.h"

@implementation YYGDesignSystem (Typography)

- (YYGTypography *)typographyBody
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    return [[YYGTypography alloc] initTypographyWithFont:font color:self.colorTextPrimary];
}

- (YYGTypography *)typographyTitle1
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    return [[YYGTypography alloc] initTypographyWithFont:font color:self.colorTextPrimary];
}

@end
