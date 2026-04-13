//
//  YYGEntitySelectViewModel.m
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitySelectViewModel.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YYGDebtSelectViewModel.h"
#import "YYGAccountSelectViewModel.h"

@interface YYGEntitySelectViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
}
@end

@implementation YYGEntitySelectViewModel

+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType allowCurrencies:(NSArray <YGCategory *> *)allowCurrencies supposedCurrency:(YGCategory *)supposedCurrency {
    
    id<YYGEntitySelectViewModelable> viewModel;
    switch(type) {
        case YGEntityTypeAccount:
            viewModel = [[YYGAccountSelectViewModel alloc] init];
            break;
        case YGEntityTypeDebt:
            viewModel = [[YYGDebtSelectViewModel alloc] init];
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGEntitySelectViewModel viewModelWith: fails." reason:@"Unknown entity type." userInfo:nil];
    }
    viewModel.customer = customer;
    viewModel.counterparty = counterpartyType;
    viewModel.allowCurrencies = allowCurrencies;
    viewModel.supposedCurrency = supposedCurrency;
    return viewModel;
}

+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType supposedCurrency:(YGCategory *)supposedCurrency {
    return [self viewModelWith:type customer:customer counterpartyType:counterpartyType allowCurrencies:nil supposedCurrency:supposedCurrency];
}

+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType {
    return [self viewModelWith:type customer:customer counterpartyType:counterpartyType allowCurrencies:nil supposedCurrency:nil];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
    }
    return self;
}

- (NSArray <YGEntity *> *)activeEntitiesOf:(YGEntityType)type {
    
    NSArray <YGEntity *> *activeEntities;
    
    // 1. Get active entities, may be filtered if source exists
    if(self.source)
        activeEntities = [p_entityManager entitiesByType:type onlyActive:YES exceptEntity:self.source exactCounterpartyType:self.counterparty];
    else
        activeEntities = [p_entityManager entitiesByType:type onlyActive:YES exactCounterpartyType:self.counterparty];
    
    // 2. Filter by allow currencies
    NSMutableArray <YGEntity *> *filteredEntities = [[NSMutableArray alloc] init];
    if(self.allowCurrencies) {
        for(YGCategory *currency in self.allowCurrencies) {
            for(YGEntity *entity in activeEntities) {
                if(currency.rowId == entity.currencyId) {
                    if([filteredEntities indexOfObject:entity] == NSNotFound)
                        [filteredEntities addObject:entity];
                }
            }
        }
    } else {
        filteredEntities = [activeEntities mutableCopy];
    }
    
    if([filteredEntities count] > 0)
        return [filteredEntities copy];
    else
        return nil;
}

#pragma mark - Methods must be overrided in child objects

- (NSString *)title {
    @throw [NSException exceptionWithName:@"YYGEntitySelectViewModel title fails." reason:@"Method must be overrided in child objects." userInfo:nil];
}

- (BOOL)showDetailText {
    @throw [NSException exceptionWithName:@"YYGEntitySelectViewModel showDetailText fails." reason:@"Method must be overrided in child objects." userInfo:nil];
}

- (NSString *)textOf:(YGEntity *)entity {
    @throw [NSException exceptionWithName:@"YYGEntitySelectViewModel textOf: fails." reason:@"Method must be overrided in child objects." userInfo:nil];
}

- (NSString *)detailTextOf:(YGEntity *)entity {
    YGCategory *currency = [p_categoryManager categoryById:entity.currencyId type:YGCategoryTypeCurrency];
    return [currency shorterName];
}

- (NSString *)unwindSegueName {
    @throw [NSException exceptionWithName:@"YYGEntitySelectViewModel unwindSegueName fails." reason:@"Method must be overrided in child objects." userInfo:nil];
}

@end
