//
//  YGExpenseEditController.h
//  Ledger
//
//  Created by Ян on 17/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGExpenseEditController : UITableViewController

@property (copy, nonatomic) YGOperation *expense;
@property (assign, nonatomic) BOOL isNewExpense;
@end
