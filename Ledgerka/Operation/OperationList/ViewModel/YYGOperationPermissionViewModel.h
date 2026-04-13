//
//  YYGOperationPermissionViewModel.h
//  Ledger
//
//  Created by Ян on 06.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOperation.h"
#import "YGEntity.h"
#import "YGCategory.h"

@interface YYGOperationPermissionViewModel : NSObject

- (BOOL)allowOperationWithDebt;
- (YYGOperationDebtPermissionType)allowOperationsWithDebt;
- (NSArray <YGCategory *> *)allowCurrenciesWith:(YYGCounterpartyType)type;
@end
