//
//  YGOperation.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YGOperationType) {
    YGOperationTypeIncome           = 1,
    YGOperationTypeExpense          = 2,
    YGOperationTypeAccountActual    = 3,
    YGOperationTypeTransfer         = 4,
    YGOperationTypeGetCredit        = 5,
    YGOperationTypeReturnCredit     = 6,
    YGOperationTypeGiveDebt         = 7,
    YGOperationTypeRepaymentDebt    = 8,
    YGOperationTypeSetDebt          = 9
};

typedef NS_OPTIONS(NSInteger, YYGOperationDebtPermissionType) {
    YYGOperationDebtPermissionTypeNone          = 0,
    YYGOperationDebtPermissionTypeSetDebt       = 1 << 0,
    YYGOperationDebtPermissionTypeGetCredit     = 1 << 1,
    YYGOperationDebtPermissionTypeReturnCredit  = 1 << 2,
    YYGOperationDebtPermissionTypeGiveDebt      = 1 << 3,
    YYGOperationDebtPermissionTypeRepaymentDebt = 1 << 4
};

@interface YGOperation : NSObject

@property NSInteger rowId;
@property YGOperationType type;
@property NSInteger sourceId;
@property NSInteger targetId;
@property double sourceSum;
@property NSInteger sourceCurrencyId;
@property double targetSum;
@property NSInteger targetCurrencyId;
@property NSDate *day;
@property NSDate *created;
@property NSDate *modified;
@property NSString *comment;
@property NSUUID *uuid;

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment uuid:(NSUUID *)uuid;

- (instancetype)initWithType:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment;


@end
