//
//  YGIncomeEditController.h
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGIncomeEditController : UITableViewController 

@property (copy, nonatomic) YGOperation *income;
@property (assign, nonatomic) BOOL isNewIncome;
@end
