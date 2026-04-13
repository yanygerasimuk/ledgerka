//
//  YYGOperationEditViewModel.m
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationEditViewModel.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YYGSetDebtViewModel.h"
#import "YYGGiveDebtViewModel.h"
#import "YYGRepaymentDebtViewModel.h"
#import "YYGGetCreditEditViewModel.h"
#import "YYGReturnCreditEditViewModel.h"

@interface YYGOperationEditViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
    YGOperationManager *p_operationManager;
}
@end

@implementation YYGOperationEditViewModel

+ (id<YYGOperationEditViewModelable>)viewModelWith:(YGOperationType)type {
    id<YYGOperationEditViewModelable> viewModel;
    switch (type) {
        case YGOperationTypeSetDebt:
            viewModel = [[YYGSetDebtViewModel alloc] init];
            break;
        case YGOperationTypeGiveDebt:
            viewModel = [[YYGGiveDebtViewModel alloc] init];
            break;
        case YGOperationTypeRepaymentDebt:
            viewModel = [[YYGRepaymentDebtViewModel alloc] init];
            break;
        case YGOperationTypeGetCredit:
            viewModel = [[YYGGetCreditEditViewModel alloc] init];
            break;
        case YGOperationTypeReturnCredit:
            viewModel = [[YYGReturnCreditEditViewModel alloc] init];
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGOperationEditViewModel viewModelWith: fails." reason:@"Can not create new viewModel for unknown operation type." userInfo:nil];
    }
    viewModel.type = type;
    return viewModel;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
        p_operationManager = [YGOperationManager sharedInstance];
    }
    return self;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type currency:(YGCategory *)currency counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"defaultEntityWith:%@ currency:%@ counterpartyType:%@", NSStringFromEntityType(type), [currency name], NSStringFromCounterpartyType(counterpartyType));
#endif
    
    YGEntity *defaultEntity; // result
    YGEntity *attachedEntity = [p_entityManager entityAttachedForType:type currencyId:currency.rowId counterpartyType:counterpartyType];
    
    // Если для операции определены возможные валюты
    if(self.allowDebtCurrencies) {

        // All entities with type and counterpartyType (if needed)
        NSArray *entitiesWithTypes;
        if(counterpartyType != YYGCounterpartyTypeNone)
            entitiesWithTypes = [p_entityManager entitiesByType:type onlyActive:YES exactCounterpartyType:counterpartyType];
        else
            entitiesWithTypes = [p_entityManager entitiesByType:type];

        NSMutableArray *entitiesWithCurrencies = [[NSMutableArray alloc] init];
        
        // All entities with allowed currencies
        if(currency) {
            if([self.allowDebtCurrencies indexOfObject:currency] != NSNotFound) {
                for(YGEntity *entity in entitiesWithTypes) {
                    if(currency.rowId == entity.currencyId) {
                        if([entitiesWithCurrencies indexOfObject:entity] == NSNotFound) {
                            [entitiesWithCurrencies addObject:entity];
                        }
                    }
                }
            }
        } else {
            for(YGCategory *currency in self.allowDebtCurrencies) {
                for(YGEntity *entity in entitiesWithTypes) {
                    if(currency.rowId == entity.currencyId) {
                        if([entitiesWithCurrencies indexOfObject:entity] == NSNotFound) {
                            [entitiesWithCurrencies addObject:entity];
                        }
                    }
                }
            }
        }
#ifdef FUNC_DEBUG
        NSLog(@"filtered entities with types and currencies: \n%@", entitiesWithCurrencies);
#endif
        if(attachedEntity && [entitiesWithCurrencies indexOfObject:attachedEntity] != NSNotFound) {
            defaultEntity = attachedEntity;
        } else if ([entitiesWithCurrencies count] == 1) {
            defaultEntity = [entitiesWithCurrencies firstObject];
        }
    } else {
        if(attachedEntity)
            defaultEntity = attachedEntity;
        else if (!attachedEntity && [p_entityManager countOfActiveEntitiesOfType:type currencyId:currency.rowId counterpartyType:counterpartyType] == 1)
            defaultEntity = [p_entityManager entityOnTopForType:type currencyId:currency.rowId counterpartyType:counterpartyType];
    }
#ifdef FUNC_DEBUG
    NSLog(@"default entity: %@", defaultEntity);
#endif
    return defaultEntity;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    YGEntity *defaultEntity;
    YGEntity *attachedEntity = [p_entityManager entityAttachedForType:type counterpartyType:counterpartyType];
    
    if(self.allowDebtCurrencies) {
        NSArray *activeEntities;
        if(counterpartyType != YYGCounterpartyTypeNone)
            activeEntities = [p_entityManager entitiesByType:type onlyActive:YES exactCounterpartyType:counterpartyType];
        else
            activeEntities = [p_entityManager entitiesByType:type];
        NSMutableArray *filteredEntities = [[NSMutableArray alloc] init];
        for(YGCategory *currency in self.allowDebtCurrencies) {
            for(YGEntity *entity in activeEntities) {
                if(currency.rowId == entity.currencyId) {
                    if([filteredEntities indexOfObject:entity] == NSNotFound) {
                        [filteredEntities addObject:entity];
                    }
                }
            }
        }
        if(attachedEntity && [filteredEntities indexOfObject:attachedEntity] != NSNotFound) {
            defaultEntity = attachedEntity;
        } else if ([filteredEntities count] == 1) {
            defaultEntity = [filteredEntities firstObject];
        }
    } else {
        if(!attachedEntity && [p_entityManager countOfActiveEntitiesOfType:type counterpartyType:counterpartyType] == 1)
            defaultEntity = [p_entityManager entityOnTopForType:type counterpartyType:counterpartyType];
        else
            defaultEntity = attachedEntity;
    }
    
#ifdef FUNC_DEBUG
    NSLog(@"default entity: %@", defaultEntity);
#endif
    return defaultEntity;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    YGEntity *defaultEntity;
    YGEntity *attachedEntity = [p_entityManager entityAttachedForType:type];
    
    // exist allow currencies
    if(self.allowDebtCurrencies) {
        NSArray *activeEntities = [p_entityManager entitiesByType:type];
        NSMutableArray *filteredEntities = [[NSMutableArray alloc] init];
        for(YGCategory *currency in self.allowDebtCurrencies) {
            for(YGEntity *entity in activeEntities) {
                if(currency.rowId == entity.currencyId) {
                    if([filteredEntities indexOfObject:entity] == NSNotFound) {
                        [filteredEntities addObject:entity];
                    }
                }
            }
        }
        
        if(attachedEntity && [filteredEntities indexOfObject:attachedEntity] != NSNotFound) {
            defaultEntity = attachedEntity;
        } else if ([filteredEntities count] == 1) {
            defaultEntity = [filteredEntities firstObject];
        }
        
    } else {
        if(!attachedEntity && [p_entityManager countOfActiveEntitiesOfType:type] == 1)
            defaultEntity = [p_entityManager entityOnTopForType:type];
        else
            defaultEntity = attachedEntity;
    }
#ifdef FUNC_DEBUG
    NSLog(@"default entity: %@", defaultEntity);
#endif
    return defaultEntity;
}

- (BOOL)isOnlyChoiceEntityWith:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"YYGOperationEditViewModel isOnlyChoiceEntityWith:%@ counterparty:%@", NSStringFromEntityType(type), NSStringFromCounterpartyType(counterpartyType));
#endif
    
    BOOL isOnlyOne = NO;
    
    if(self.allowDebtCurrencies) {
        NSArray *activeEntities = [p_entityManager entitiesByType:type onlyActive:YES exactCounterpartyType:counterpartyType];
        NSMutableArray *filteredEntities = [[NSMutableArray alloc] init];
        for(YGCategory *currency in self.allowDebtCurrencies) {
            for(YGEntity *entity in activeEntities) {
                if(currency.rowId == entity.currencyId) {
                    if([filteredEntities indexOfObject:entity] == NSNotFound) {
                        [filteredEntities addObject:entity];
                    }
                }
            }
        }
        
        if ([filteredEntities count] == 1)
            isOnlyOne = YES;
    } else {
        if([p_entityManager countOfActiveEntitiesOfType:type counterpartyType:counterpartyType] <= 1)  // may be ==1?
            isOnlyOne = YES;
    }
    
#ifdef FUNC_DEBUG
    NSLog(@"isOnlyOneChoice: %@", isOnlyOne ? @"YES" : @"NO");
#endif
    
    return isOnlyOne;
}

- (BOOL)isOnlyChoiceEntityWith:(YGEntityType)type {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"YYGOperationEditViewModel isOnlyChoiceEntityWith:%@", NSStringFromEntityType(type));
#endif
    
    BOOL isOnlyOne = NO;
    
    if(self.allowDebtCurrencies) {
        NSArray *activeEntities = [p_entityManager entitiesByType:type onlyActive:YES];
        NSMutableArray *filteredEntities = [[NSMutableArray alloc] init];
        for(YGCategory *currency in self.allowDebtCurrencies) {
            for(YGEntity *entity in activeEntities) {
                if(currency.rowId == entity.currencyId) {
                    if([filteredEntities indexOfObject:entity] == NSNotFound) {
                        [filteredEntities addObject:entity];
                    }
                }
            }
        }
        
        if ([filteredEntities count] == 1)
            isOnlyOne = YES;
    } else {
        if([p_entityManager countOfActiveEntitiesOfType:type] <= 1)  // may be ==1?
            isOnlyOne = YES;
    }
    
#ifdef FUNC_DEBUG
    NSLog(@"isOnlyOneChoice: %@", isOnlyOne ? @"YES" : @"NO");
#endif
    
    return isOnlyOne;
}

- (YGCategory *)currencyWithId:(NSInteger)rowId {
    return [p_categoryManager categoryById:rowId type:YGCategoryTypeCurrency];
}

- (NSInteger)addOperation:(YGOperation *)operation {
    return [p_operationManager addOperation:operation];
}

- (void)updateOperation:(YGOperation *)operation withNew:(YGOperation *)newOperation {
    [p_operationManager updateOperation:operation withNew:newOperation];
}

- (void)removeOperation:(YGOperation *)operation {
    [p_operationManager removeOperation:operation];
}

- (void)recalcBalanceWith:(YGOperation *)operation {
    
    switch (operation.type) {
        case YGOperationTypeSetDebt: {
            YGEntity *targetDebt = [p_entityManager entityById:operation.targetId type:YGEntityTypeDebt];
            [p_entityManager recalcSumOfDebt:targetDebt forOperation:operation];
        }
            break;
        case YGOperationTypeGiveDebt:
        case YGOperationTypeReturnCredit: {
            YGEntity *sourceAccount = [p_entityManager entityById:operation.sourceId type:YGEntityTypeAccount];
            [p_entityManager recalcSumOfAccount:sourceAccount forOperation:operation];
            
            YGEntity *targetDebt = [p_entityManager entityById:operation.targetId type:YGEntityTypeDebt];
            [p_entityManager recalcSumOfDebt:targetDebt forOperation:operation];
        }
            break;
        case YGOperationTypeRepaymentDebt:
        case YGOperationTypeGetCredit: {
            YGEntity *sourceDebut = [p_entityManager entityById:operation.sourceId type:YGEntityTypeDebt];
            [p_entityManager recalcSumOfDebt:sourceDebut forOperation:operation];
            
            YGEntity *targetAccount = [p_entityManager entityById:operation.targetId type:YGEntityTypeAccount];
            [p_entityManager recalcSumOfAccount:targetAccount forOperation:operation];
        }
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGOperationEditViewModel" reason:@"Recalc balance for the operation is not realized." userInfo:nil];
    }
}

- (id<YYGRowIdAndNameIdentifiable>)entityWithId:(NSInteger)rowId type:(YGEntityType)type {
    return [p_entityManager entityById:rowId type:type];
}

- (NSString *)textSelectSource {
    @throw [NSException exceptionWithName:@"YYGOperationEditViewModel textSelectSource fails." reason:@"Method must be overrided in child classes." userInfo:nil];
}

- (NSString *)textSelectTarget {
    @throw [NSException exceptionWithName:@"YYGOperationEditViewModel textSelectTarget fails." reason:@"Method must be overrided in child classes." userInfo:nil];
}

- (BOOL)checkPiredForSameCurrency {
    @throw [NSException exceptionWithName:@"YYGOperationEditViewModel checkPiredForSameCurrency fails." reason:@"Method must be overrided in child classes." userInfo:nil];
}

@end
