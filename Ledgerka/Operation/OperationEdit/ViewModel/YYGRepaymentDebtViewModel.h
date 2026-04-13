//
//  YYGRepaymentDebtViewModel.h
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationEditViewModel.h"

@interface YYGRepaymentDebtViewModel : YYGOperationEditViewModel <YYGOperationEditViewModelable>

// UI
- (NSString *)title;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;

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

- (BOOL)sameSourceAndTarget;
- (BOOL)sameSourceAndTargetSum;
@end
