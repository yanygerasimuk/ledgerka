//
//  YYGCategorySelectController.h
//  Ledger
//
//  Created by Ян on 02.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGCategorySelectViewModel.h"

@interface YYGCategorySelectController : UITableViewController

@property (nonatomic, strong) id<YYGCategorySelectViewModelable> viewModel;

@end
