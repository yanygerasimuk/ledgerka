//
//  YYGTableViewControllerInput.h
//  Ledger
//
//  Created by Yan Gerasimuk on 18.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewModel.h"

// #import "YYGNavBarViewModel.h"

@class YYGErrorViewModel;
@class YYGNavBarViewModel;
@class YYGBottomButtonViewModel;
@class YYGTwoTextsViewModel;

@protocol YYGTableViewControllerInput

//- (void)hidePullRefresh;
//- (void)reloadData;

- (void)showLoading;
- (void)hideLoading;
- (void)showInfoWithViewModel:(YYGTwoTextsViewModel * _Nonnull)viewModel;
- (void)hideInfoView;

- (void)configureTableWithViewModel:(YYGTableViewModel * _Nonnull)tableViewModel;
- (void)configureNavBarWithViewModel:(YYGNavBarViewModel * _Nonnull)navBarViewModel;
- (void)configureBottomButtonsWithFirstViewModel:(YYGBottomButtonViewModel * _Nullable)firstViewModel
                                 secondViewModel:(YYGBottomButtonViewModel * _Nullable)secondViewModel;
@end
