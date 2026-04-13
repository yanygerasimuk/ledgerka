//
//  YGCurrencyEditController.h
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"
#import "YYGCurrencyViewModel.h"

@interface YGCurrencyEditController : UITableViewController

@property (strong, nonatomic) YYGCurrencyViewModel *viewModel;

@end
