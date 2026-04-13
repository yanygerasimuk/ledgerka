//
//  YYGEntitySelectViewModel.h
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGEntity.h"
#import "YGCategory.h"

typedef NS_ENUM(NSInteger, YYGEntitySelectCustomer) {
    YYGEntitySelectForOperationEditSource = 1,
    YYGEntitySelectForOperationEditTarget = 2
};

@protocol YYGEntitySelectViewModelable

@property (nonatomic, strong) YGEntity *source;
@property (nonatomic, strong) YGEntity *target;
@property (nonatomic, assign) YYGEntitySelectCustomer customer;
@property (nonatomic, assign) YYGCounterpartyType counterparty;
@property (nonatomic, strong) NSArray <YGCategory *> *allowCurrencies;
@property (nonatomic, strong) YGCategory *supposedCurrency;

- (NSString *)title;
- (NSArray <YGEntity *> *)getEntities;
- (BOOL)showDetailText;
- (NSString *)textOf:(YGEntity *)entity;
- (NSString *)detailTextOf:(YGEntity *)entity;
- (NSString *)unwindSegueName;
@end

@interface YYGEntitySelectViewModel : NSObject

// Fabric of custom viewModels
+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType allowCurrencies:(NSArray <YGCategory *> *)allowCurrencies supposedCurrency:(YGCategory *)supposedCurrency;
+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType supposedCurrency:(YGCategory *)supposedCurrency;
+ (id<YYGEntitySelectViewModelable>)viewModelWith:(YGEntityType)type customer:(YYGEntitySelectCustomer)customer counterpartyType:(YYGCounterpartyType)counterpartyType;

// Common source -> target properties
@property (nonatomic, strong) YGEntity *source;
@property (nonatomic, strong) YGEntity *target;
@property (nonatomic, assign) YYGEntitySelectCustomer customer;
@property (nonatomic, assign) YYGCounterpartyType counterparty;
@property (nonatomic, strong) NSArray <YGCategory *> *allowCurrencies;
@property (nonatomic, strong) YGCategory *supposedCurrency;

- (instancetype)init;

- (NSArray <YGEntity *> *)activeEntitiesOf:(YGEntityType)type;
- (NSString *)detailTextOf:(YGEntity *)entity;
@end
