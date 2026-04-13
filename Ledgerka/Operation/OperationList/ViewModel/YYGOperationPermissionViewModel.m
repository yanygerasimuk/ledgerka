//
//  YYGOperationPermissionViewModel.m
//  Ledger
//
//  Created by Ян on 06.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationPermissionViewModel.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"

@interface YYGOperationPermissionViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
}
@end

@implementation YYGOperationPermissionViewModel
- (instancetype)init {
    self = [super init];
    if(self) {
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
    }
    return self;
}

- (BOOL)allowOperationWithDebt {
    if([p_entityManager countOfActiveEntitiesOfType:YGEntityTypeDebt] > 0)
        return YES;
    else
        return NO;
}

/**
 Rules:
 0. Select only active debts,
 1. SetDebt allow for all debts,
 2. Select only debts for accounts with same currency,
 3. If exists debt, then allow getDebt and repaymentDebt,
 4. If exists credit, then allow getCredit and returnCredit.

 @return Flag with permissions.
 */
- (YYGOperationDebtPermissionType)allowOperationsWithDebt {
    
    YYGOperationDebtPermissionType permissions = YYGOperationDebtPermissionTypeNone;
    NSArray *debts = [p_entityManager entitiesByType:YGEntityTypeDebt onlyActive:YES];
    if([debts count] > 0)
        permissions = permissions | YYGOperationDebtPermissionTypeSetDebt;
    
    NSArray *accounts = [p_entityManager entitiesByType:YGEntityTypeAccount onlyActive:YES];
    NSMutableArray <YGEntity *> *debtsWithAccounts = [[NSMutableArray alloc] init];
    
    for(YGEntity *debt in debts) {
        for(YGEntity *account in accounts) {
            if(debt.currencyId == account.currencyId) {
                [debtsWithAccounts addObject:debt];
                break;
            }
        }
    }
    
    if([debtsWithAccounts count] > 0) {
        
        BOOL isDebtExists = NO;
        BOOL isCreditExists = NO;
        for(YGEntity *debt in debtsWithAccounts) {
            if(debt.counterpartyType == YYGCounterpartyTypeDebtor)
                isDebtExists = YES;
            else if(debt.counterpartyType == YYGCounterpartyTypeCreditor)
                isCreditExists = YES;
        }
        
        if(isDebtExists)
            permissions = permissions | YYGOperationDebtPermissionTypeGiveDebt | YYGOperationDebtPermissionTypeRepaymentDebt;
        if(isCreditExists)
            permissions = permissions | YYGOperationDebtPermissionTypeGetCredit | YYGOperationDebtPermissionTypeReturnCredit;
    }
    return permissions;
}

/**
 Get list of currencies allowed for passed debt counterparty type.

 @param type Counterparty type of checked debt.
 @return Currencies list of active debts. So allowed for paired accounts.
 */
- (NSArray <YGCategory *> *)allowCurrenciesWith:(YYGCounterpartyType)type {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSMutableArray <YGCategory *> *currenciesInDebts = [[NSMutableArray alloc] init];
    
    // Get active debts
    NSArray *debts = [p_entityManager entitiesByType:YGEntityTypeDebt onlyActive:YES exactCounterpartyType:type];
    
    // Get currencies in debts
    for(YGEntity *debt in debts) {
        YGCategory *currency = [p_categoryManager categoryById:debt.currencyId type:YGCategoryTypeCurrency];
        if([currenciesInDebts indexOfObject:currency] == NSNotFound)
            [currenciesInDebts addObject:currency];
    }
    
    // Get currencies with paired account
    NSMutableArray <YGCategory *> *currenciesWithPairAccount = [[NSMutableArray alloc] init];
    NSArray <YGEntity *> *activeAccounts = [p_entityManager entitiesByType:YGEntityTypeAccount onlyActive:YES];
    for(YGCategory *currency in currenciesInDebts) {
        for(YGEntity *account in activeAccounts) {
            if(currency.rowId == account.currencyId) {
                if([currenciesWithPairAccount indexOfObject:currency] == NSNotFound) {
                    [currenciesWithPairAccount addObject:currency];
                }
            }
        }
    }
    
#ifdef FUNC_DEBUG
    NSLog(@"allowed currencies: %@", currenciesWithPairAccount);
#endif
    
    if([currenciesWithPairAccount count] > 0)
        return [currenciesWithPairAccount copy];
    else
        return nil;
}

@end

