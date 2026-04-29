//
//  YYGBottomButtonsView.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 23.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGBottomButtonViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGBottomButtonsView : UIView

- (instancetype)init;
- (instancetype)initWithFirstViewModel:(YYGBottomButtonViewModel * _Nullable)firstViewModel
                       secondViewModel:(YYGBottomButtonViewModel * _Nullable)secondViewModel;

- (void)configureWithFirstViewModel:(YYGBottomButtonViewModel * _Nullable)firstViewModel
                    secondViewModel:(YYGBottomButtonViewModel * _Nullable)secondViewModel;

- (void)configureWithViewModel:(YYGBottomButtonViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
