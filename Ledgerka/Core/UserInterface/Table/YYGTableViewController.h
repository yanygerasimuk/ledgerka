//
//  YYGTableViewController.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 17.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGDesignSystem.h"
#import "YYGTableViewControllerInput.h"

@protocol YYGTableViewControllerOutput;

NS_ASSUME_NONNULL_BEGIN


@interface YYGTableViewController : UIViewController
<
YYGTableViewControllerInput
>

@property (nonatomic, strong) id<YYGTableViewControllerOutput> output;

- (instancetype)initWithDesignSystem:(YYGDesignSystem *)designSystem;

@end

NS_ASSUME_NONNULL_END
