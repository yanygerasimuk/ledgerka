//
//  YYGDesignSystem+Typography.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGDesignSystem.h"
#import "YYGTypography.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGDesignSystem (Typography)

@property(nonatomic, readonly, strong) YYGTypography *typographyBody;
@property(nonatomic, readonly, strong) YYGTypography *typographyTitle1;

@end

NS_ASSUME_NONNULL_END
