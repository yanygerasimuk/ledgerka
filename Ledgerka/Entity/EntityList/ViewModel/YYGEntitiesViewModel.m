//
//  YYGEntitiesViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitiesViewModel.h"
#import "YYGAccountsViewModel.h"
#import "YYGDebtsViewModel.h"
#import "YGCategory.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGConfig.h"
#import "YGTools.h"

@interface YYGEntitiesViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
}
@end

@implementation YYGEntitiesViewModel

@synthesize entities = _entities;

+ (id<YYGEntitiesViewModelable>)viewModelWith:(YGEntityType)type {
    id<YYGEntitiesViewModelable> viewModel;
    switch(type){
        case YGEntityTypeAccount:
            viewModel = [[YYGAccountsViewModel alloc] init];
            viewModel.type = YGEntityTypeAccount;
            break;
        case YGEntityTypeDebt:
            viewModel = [[YYGDebtsViewModel alloc] init];
            viewModel.type = YGEntityTypeDebt;
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGEntitiesViewModel.viewModelWith: fails" reason:@"Unknown entity type" userInfo:nil];
    }
    return viewModel;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(updateCache)
                       name:@"EntityManagerCacheUpdateEvent"
                     object:nil];
        [center addObserver:self
                   selector:@selector(updateCacheAfterDecimalFractionChange)
                       name:@"HideDecimalFractionInListsChangedEvent"
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)currencyNameWithId:(NSInteger)currencyId {
    YGCategory *currency = [p_categoryManager categoryById:currencyId type:YGCategoryTypeCurrency];
    return [currency shorterName];
}

- (NSString *)title {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel title fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)noDataMessage {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel noDataMessage fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (BOOL)showDebtType {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel showDebtType fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (BOOL)isEnoughConditionsWithFeedback:(void (^)(NSString *))feedback {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel isEnoughConditionsWithFeedback: fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (BOOL)hasActiveCategoryWith:(YGCategoryType)type {
    NSArray *categories = [p_categoryManager categoriesByType:type onlyActive:YES];
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

#pragma mark - Update cache

- (void)updateCache {
    _entities = [p_entityManager.entities valueForKey:NSStringFromEntityType(self.type)];
    [self.cacheUpdateEvent sendNext:@(YES)];
}

- (void)updateCacheAfterDecimalFractionChange {
    YGConfig *config = [YGTools config];
    BOOL isHide = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    [self.decimalFractionHideChangeEvent sendNext:@(isHide)];
    [self updateCache];
}

#pragma mark - Setters & getters

- (NSMutableArray<YGEntity *> *)entities {
    if(!_entities){
        _entities = [p_entityManager.entities valueForKey:NSStringFromEntityType(self.type)];
    }
    return _entities;
}

- (RACSubject *)cacheUpdateEvent {
    if(!_cacheUpdateEvent)
        _cacheUpdateEvent = [[RACSubject alloc] init];
    return _cacheUpdateEvent;
}

- (RACSubject *)decimalFractionHideChangeEvent {
    if(!_decimalFractionHideChangeEvent)
        _decimalFractionHideChangeEvent = [[RACSubject alloc] init];
    return _decimalFractionHideChangeEvent;
}

@end
