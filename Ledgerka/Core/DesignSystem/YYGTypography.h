//
//  YYGTypography.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 Типографика:

 включает в себя шрифт, размер и цвет.

 */

//typedef NS_ENUM(NSInteger, YYGTypographyRole)
//{
//    YYGTypographyRole    = 0,
//    YYGTypographyRole   = 1,
//    YYGTypographyRole  = 2,
//    YYGTypographyRole    = 3
//};


NS_ASSUME_NONNULL_BEGIN


@interface YYGTypography : NSObject

@property(nonatomic, readonly, strong) UIFont *font;
@property(nonatomic, readonly, strong) UIColor *color;

- (instancetype)initTypographyWithFont:(UIFont *)font
                                 color:(UIColor *)color;

- (instancetype)initTypographySystemWithSize:(CGFloat)size
                                      weight:(UIFontWeight)weight
                                       color:(UIColor *)color;

- (NSAttributedString *)attributedWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
