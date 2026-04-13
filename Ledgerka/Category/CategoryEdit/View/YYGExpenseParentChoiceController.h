//
//  YYGExpenseParentChoiceController.h
//  Ledger
//
//  Created by Ян on 15/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGCategory;

@interface YYGExpenseParentChoiceController : UITableViewController

/// Expense category for which we choose new parent
@property (copy, nonatomic) YGCategory *expenseCategory;

/// Source expense category
@property (copy, nonatomic) YGCategory *sourceParentCategory;

/// Target expense category
@property (copy, nonatomic) YGCategory *targetParentCategory;

@end
