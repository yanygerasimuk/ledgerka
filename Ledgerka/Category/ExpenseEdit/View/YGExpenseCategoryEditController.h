//
//  YGExpenseCategoryEditController.h
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"
#import "YYGExpenseViewModel.h"

@interface YGExpenseCategoryEditController : UITableViewController

@property (strong, nonatomic) YYGExpenseViewModel *viewModel;

//@property (assign, nonatomic) YGCategoryType categoryType;
//@property (copy, nonatomic) YGCategory *expenseCategory;
//@property (copy, nonatomic) YGCategory *expenseCategoryParent;
//@property (assign, nonatomic) BOOL isNewExpenseCategory;

@end
