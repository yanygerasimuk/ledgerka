//
//  YYGEntityEditController.h
//  Ledger
//
//  Created by Ян on 24.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGEntityEditViewModel.h"

@class YGEntity, YGCategory;

@interface YYGEntityEditController : UITableViewController

@property (strong, nonatomic) id<YYGEntityEditViewModelable> viewModel;

@end
