//
//  YGIncomeSourceChoiceController.h
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGCategory;

typedef NS_ENUM(NSInteger, YGIncomeSourceChoiceСustomer) {
    YGIncomeSourceChoiceСustomerIncome
};

@interface YGIncomeSourceChoiceController : UITableViewController

@property (assign, nonatomic) YGIncomeSourceChoiceСustomer customer;
@property (copy, nonatomic) YGCategory *sourceIncome;
@property (copy, nonatomic) YGCategory *targetIncome;
@end
