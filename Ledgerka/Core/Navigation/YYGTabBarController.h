//
//  YYGTabBarController.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 16.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGDesignSystem.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGTabBarController : UITabBarController

- (instancetype)initWithDesignSystem:(YYGDesignSystem *)ds;

@end

NS_ASSUME_NONNULL_END
