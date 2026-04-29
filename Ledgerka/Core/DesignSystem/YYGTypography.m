//
//  YYGTypography.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTypography.h"


@implementation YYGTypography

- (instancetype)initTypographyWithFont:(UIFont *)font
                                 color:(UIColor *)color
{
    self = [super init];
    if (self)
    {
        _font = font;
        _color = color;
    }
    return self;
}

- (instancetype)initTypographySystemWithSize:(CGFloat)size
                                      weight:(UIFontWeight)weight
                                       color:(UIColor *)color
{
    UIFont *font = [UIFont systemFontOfSize:size weight:weight];
    return [self initTypographyWithFont:font color:color];
}

- (NSAttributedString *)attributedWithString:(NSString *)string
{
    NSDictionary *attributes = @{
        NSFontAttributeName: self.font,
        NSForegroundColorAttributeName: self.color
    };

    NSAttributedString *result = [[NSAttributedString alloc] initWithString:string
                                                                 attributes:attributes];
    return result;
}

@end
