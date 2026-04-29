//
//  YYGBottomButton.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYGBottomButtonViewModel;

typedef NS_ENUM(NSInteger, YYGBottomButtonStyle)
{
    YYGBottomButtonStylePrimary     = 0,
    YYGBottomButtonStyleSecondary   = 1,
    YYGBottomButtonStyleDestructive = 2,
    YYGBottomButtonStyleDisabled    = 3,
    YYGBottomButtonStyleLoading     = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface YYGBottomButton : UIButton

- (instancetype)initWithViewModel:(YYGBottomButtonViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
