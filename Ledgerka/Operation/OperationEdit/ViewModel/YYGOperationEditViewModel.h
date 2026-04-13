//
//  YYGOperationEditViewModel.h
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOperation.h"
#import "YGEntity.h"
#import "YGCategory.h"
#import "YYGObject.h"

@protocol YYGOperationEditViewModelable

@property (nonatomic, assign) YGOperationType type;
@property (nonatomic, strong) YGOperation *operation;
@property (nonatomic, strong) NSArray <YGCategory *> *allowDebtCurrencies;

// UI
- (NSString *)title;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;

// Source -> target
- (BOOL)showSource;
- (id<YYGRowIdAndNameIdentifiable>)defaultSource;
- (id<YYGRowIdAndNameIdentifiable>)defaultSourceWithCurrency:(YGCategory *)currency;
- (BOOL)isOnlyChoiceSource;
- (BOOL)showSourceSum;
- (BOOL)showTarget;
- (id<YYGRowIdAndNameIdentifiable>)defaultTarget;
- (id<YYGRowIdAndNameIdentifiable>)defaultTargetWithCurrency:(YGCategory *)currency;

- (BOOL)isOnlyChoiceTarget;
- (BOOL)showTargetSum;

- (BOOL)hasSumAndCurrency:(id<YYGRowIdAndNameIdentifiable>)object;
- (YGCategory *)currencyOf:(id<YYGSumAndCurrencyIdentifiable>)object;

- (BOOL)isSourceNeedForSave;
- (BOOL)isSourceSumNotNullNeedForSave;
- (BOOL)isTargetNeedForSave;
- (BOOL)isTargetSumNotNullNeedForSave;

- (NSInteger)addOperation:(YGOperation *)operation;
- (void)updateOperation:(YGOperation *)operation withNew:(YGOperation *)newOperation;
- (void)removeOperation:(YGOperation *)operation;

- (void)recalcBalanceWith:(YGOperation *)operation;

- (id<YYGRowIdAndNameIdentifiable>)sourceOf:(YGOperation *)operation;
- (id<YYGRowIdAndNameIdentifiable>)targetOf:(YGOperation *)operation;

- (NSInteger)heightForRow:(NSInteger)row inSection:(NSInteger)section;

// Navigation
- (BOOL)isSelectableRowAt:(NSInteger)row inSection:(NSInteger)section;
- (NSString *)selectSchemeNameForRow:(NSInteger)row inSection:(NSInteger)section;
- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section supposedCurrency:(YGCategory *)supposedCurrency;
- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section;

// Text
- (NSString *)textSelectSource;
- (NSString *)textSelectTarget;

- (BOOL)checkPiredForSameCurrency;

/// Same source and target, ex: actualAccount or setDebt
- (BOOL)sameSourceAndTarget;

/// Same source and target sum, ex: all debt operations
- (BOOL)sameSourceAndTargetSum;

@end

@interface YYGOperationEditViewModel : NSObject
// Fabric
+ (id<YYGOperationEditViewModelable>)viewModelWith:(YGOperationType)type;

// YYGOperationEditViewModelable
@property (nonatomic, assign) YGOperationType type;
@property (nonatomic, strong) YGOperation *operation;
@property (nonatomic, strong) NSArray <YGCategory *> *allowDebtCurrencies;

// Helpers
- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type currency:(YGCategory *)currency counterpartyType:(YYGCounterpartyType)counterpartyType;
- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType;
- (id<YYGRowIdAndNameIdentifiable>)defaultEntityWith:(YGEntityType)type;

- (BOOL)isOnlyChoiceEntityWith:(YGEntityType)type;
- (BOOL)isOnlyChoiceEntityWith:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType;

- (YGCategory *)currencyWithId:(NSInteger)rowId;

- (NSInteger)addOperation:(YGOperation *)operation;
- (void)updateOperation:(YGOperation *)operation withNew:(YGOperation *)newOperation;
- (void)removeOperation:(YGOperation *)operation;

- (void)recalcBalanceWith:(YGOperation *)operation;

- (id<YYGRowIdAndNameIdentifiable>)entityWithId:(NSInteger)rowId type:(YGEntityType)type;
@end
