//
//  YYGEntityEditViewModel.m
//  Ledger
//
//  Created by Ян on 24.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntityEditViewModel.h"
#import "YYGAccountEditViewModel.h"
#import "YYGDebtEditViewModel.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"

@interface YYGEntityEditViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
}
@end

@implementation YYGEntityEditViewModel

+ (id<YYGEntityEditViewModelable>)viewModelWith:(YGEntityType)type {
    
    switch(type) {
        case YGEntityTypeAccount:
            return [[YYGAccountEditViewModel alloc] init];
        case YGEntityTypeDebt:
            return [[YYGDebtEditViewModel alloc] init];
        default:
            @throw [NSException exceptionWithName:@"Unknown entity type" reason:@"YYGEntityEditViewModel.viewModelWith: failed. Unknown entity type" userInfo:nil];
            return nil; // ?
    }
}

- (instancetype)init {
    self = [super init];
    if(self){
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
    }
    return self;
}

/**
 Return attached currency or first currency if it only one.

 @return Default currency.
 */
- (YGCategory *)defaultCurrency {
    return [p_categoryManager defaultCategoryOfType:YGCategoryTypeCurrency];
}

- (YGCategory *)currencyOf:(YGEntity *)entity {
    return [p_categoryManager categoryById:entity.currencyId type:YGCategoryTypeCurrency];
}

- (void)remove:(YGEntity *)entity {
    [p_entityManager removeEntity:entity];
}

- (void)activate:(YGEntity *)entity {
    [p_entityManager activateEntity:entity];
}

- (void)deactivate:(YGEntity *)entity {
    [p_entityManager deactivateEntity:entity];
}

- (void)add:(YGEntity *)entity {
    [p_entityManager addEntity:entity];
}

- (void)update:(YGEntity *)entity {
    [p_entityManager updateEntity:entity];
}

- (BOOL)isExistLinkedOperationsWith:(YGEntity *)entity {
    return [p_entityManager isExistLinkedOperationsForEntity:entity];
}

- (BOOL)isExistDuplicateOf:(YGEntity *)entity {
    return [p_entityManager isExistDuplicateOfEntity:entity];
}

- (NSInteger)countOfActiveCategoriesOf:(YGCategoryType)type {
    return [p_categoryManager countOfActiveCategoriesForType:type];
}

- (YGCategory *)counterpartyOf:(YGEntity *)entity {
    return [p_categoryManager categoryById:entity.counterpartyId type:YGCategoryTypeCounterparty];
}

- (YGCategory *)defaultCounterparty {
    return [p_categoryManager defaultCategoryOfType:YGCategoryTypeCounterparty];
}

- (BOOL)isOnlyOneActive:(YGCategory *)category {
    return ![p_categoryManager hasActiveCategoryForTypeExceptCategory:category];
}

- (BOOL)canDelete {
    if(self.entity) {
        if([self isExistLinkedOperationsWith:self.entity])
            return NO;
        else
            return YES;
    } else
        return NO;
}

- (BOOL)canChangeCounterparty {
    if(![self isExistLinkedOperationsWith:self.entity]
       && [self countOfActiveCategoriesOf:YGCategoryTypeCounterparty] > 1)
        return YES;
    else
        return NO;
}

- (BOOL)canChangeCounterpartyType {
    if(self.entity) {
        if([self isExistLinkedOperationsWith:self.entity])
            return NO;
        else
            return YES;
    } else
        return YES;
}

- (BOOL)canChangeCurrency {
    if(self.entity) {
        if([self isExistLinkedOperationsWith:self.entity])
            return NO;
        else {
            if([self countOfActiveCategoriesOf:YGCategoryTypeCurrency] > 1)
                return YES;
            else
                return NO;
        }
    } else {
        if([self countOfActiveCategoriesOf:YGCategoryTypeCurrency] > 1)
            return YES;
        else
            return NO;
    }
}

- (BOOL)hasAccountWithCurrencyId:(NSInteger)currencyId {
    BOOL hasAccount = NO;
    NSArray <YGEntity *> *accounts = [p_entityManager entitiesByType:YGEntityTypeAccount onlyActive:YES];
    for(YGEntity *account in accounts) {
        if(currencyId == account.currencyId) {
            hasAccount = YES;
            break;
        }
    }
    return hasAccount;
}

@end
