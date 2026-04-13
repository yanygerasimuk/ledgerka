//
//  YGExpenseCategoryChoiceController.h
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGCategory;

@interface YGExpenseCategoryChoiceController : UITableViewController

@property (copy, nonatomic) YGCategory *sourceCategory;
@property (copy, nonatomic) YGCategory *targetCategory;
@end
