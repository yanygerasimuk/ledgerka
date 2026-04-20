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

@protocol YYGTableViewControllerInput

//- (void)setupUI;
//
//- (void)showEmptyView;
//- (void)hideEmptyView;
//
//- (void)showLoading;
//- (void)hideLoading;
//
//- (void)hidePullRefresh;
//
//- (void)showErrorWithViewModel:(YYGErrorViewModel *)viewModel;
//
////- (void)showWithViewModel:(YYGTableViewModel *)viewModel;
//
//- (void)reloadData;

- (void)configureTableWithViewModel:(YYGTableViewModel *)tableViewModel;
- (void)configureNavBarWithViewModel:(YYGNavBarViewModel *)navBarViewModel;

@end
