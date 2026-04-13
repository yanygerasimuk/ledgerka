//
//  YGCategoryViewController.h
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"
#import "YYGCategoriesViewModel.h"

@interface YGCategoryViewController : UITableViewController

@property (assign, nonatomic) YGCategoryType categoryType;

@property (strong, nonatomic) id<YYGCategoriesViewModelable> viewModel;

@end
