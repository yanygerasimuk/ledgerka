//
//  YGCategoryDefaultEditController.h
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"
#import "YYGCategoryViewModel.h"

@interface YGCategoryDefaultEditController : UITableViewController

@property (strong, nonatomic) id<YYGCategoryViewModelable> viewModel;

@end
