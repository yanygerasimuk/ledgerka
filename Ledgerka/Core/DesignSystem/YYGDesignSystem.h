//
//  YYGDesignSystem.h
//  Ledger
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "YYGOptionable.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGDesignSystem : NSObject

+ (YYGDesignSystem *)shared;
//- (instancetype)initWithOptions:(id<YYGOptionable>) options;

@property (nonatomic, readonly, strong) UIColor *colorContentPrimary;
@property (nonatomic, readonly, strong) UIColor *colorContentSecondary;
@property (nonatomic, readonly, strong) UIColor *colorSystemWarning;
@property (nonatomic, readonly, strong) UIColor *colorBordersDefault;
@property (nonatomic, readonly, strong) UIColor *colorCallToActionDefault;
@property (nonatomic, readonly, strong) UIColor *colorBackgroundSystem;
@property (nonatomic, readonly, strong) UIColor *colorBackgroundPrimary;
@property (nonatomic, readonly, strong) UIColor *colorBackgroundSecondary;

@property (nonatomic, readonly, strong) UIColor *colorBackgroundOcean;
@property (nonatomic, readonly, strong) UIColor *colorBackgroundIsland;

@property (nonatomic, readonly, strong) UIColor *colorTextPrimary;
@property (nonatomic, readonly, strong) UIColor *colorTextSecondary;
@property (nonatomic, readonly, strong) UIColor *colorTextMint;

- (UIFont *)fontHeadMed;
- (UIFont *)fontTitleMed;
- (UIFont *)fontBodyMMed;
- (UIFont *)fontBodyMReg;
- (UIFont *)fontBodySReg;
- (UIFont *)fontCaption;
@end

NS_ASSUME_NONNULL_END
