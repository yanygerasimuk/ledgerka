//
//  YGDateChoiceController.h
//  Ledger
//
//  Created by Ян on 17/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YGDateChoiceСustomer) {
    YGDateChoiceСustomerExpense,
    YGDateChoiceСustomerIncome,
    YGDateChoiceСustomerAccountActual,
    YGDateChoiceСustomerTransfer,
    YGDateChoiceCustomerOperation
};

@interface YGDateChoiceController : UIViewController

@property (assign, nonatomic) YGDateChoiceСustomer customer;
@property (strong, nonatomic) NSDate *sourceDate;
@property (strong, nonatomic) NSDate *targetDate;
@end
