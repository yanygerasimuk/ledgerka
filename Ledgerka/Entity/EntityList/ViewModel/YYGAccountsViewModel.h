//
//  YYGAccountsViewModel.h
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitiesViewModel.h"

@interface YYGAccountsViewModel : YYGEntitiesViewModel <YYGEntitiesViewModelable>

- (NSString *)title;
- (NSString *)noDataMessage;
- (NSString *)currencyNameWithId:(NSInteger)currencyId;
- (BOOL)isEnoughConditionsWithFeedback:(void(^)(NSString *message))feedback;
- (BOOL)showDebtType;
@end
