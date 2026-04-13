//
//  YYGRepaymentDebtViewModel.m
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGRepaymentDebtViewModel.h"
#import "YYGEntitySelectViewModel.h"

@implementation YYGRepaymentDebtViewModel

- (NSString *)title {
    return NSLocalizedString(@"OPERATION_EDIT_FORM_REPAYMENT_DEBT_TITLE", @"Title for repayment debt operation");
}

- (NSInteger)numberOfSections {
    return 4;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if(section == 0)
        rows = 1;
    else if(section == 1)
        rows = 4;
    else if(section == 2)
        rows = 1;
    else if(section == 3)
        rows = 2;
    else
        @throw [NSException exceptionWithName:@"YYGRepaymentDebtViewModel numberOfRowsInSection: fails." reason:@"Unknown section number." userInfo:nil];
    return rows;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch(section) {
        case 0:
            break;
        case 1:
            title = NSLocalizedString(@"OPERATION_EDIT_FORM_REPAYMENT_DEBT_SECTION", @"Section title for repayment debt in operation edit form");
            break;
        case 2:
        case 3:
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGRepaymentDebtEditViewModel titleForHeaderInSection: fails." reason:@"Unknown section number." userInfo:nil];
    }
    return title;
}

#pragma mark - Source

- (BOOL)showSource {
    return YES;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultSource {
    return [super defaultEntityWith:YGEntityTypeDebt counterpartyType:YYGCounterpartyTypeDebtor];
}

- (id<YYGRowIdAndNameIdentifiable>)defaultSourceWithCurrency:(YGCategory *)currency {
    return [super defaultEntityWith:YGEntityTypeDebt currency:currency counterpartyType:YYGCounterpartyTypeDebtor];
}

- (BOOL)isOnlyChoiceSource {
    return [super isOnlyChoiceEntityWith:YGEntityTypeDebt counterpartyType:YYGCounterpartyTypeDebtor];
}

- (BOOL)showSourceSum {
    return NO;
}

#pragma mark - Target

- (BOOL)showTarget {
    return YES;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultTarget {
    return [super defaultEntityWith:YGEntityTypeAccount];
}

- (id<YYGRowIdAndNameIdentifiable>)defaultTargetWithCurrency:(YGCategory *)currency {
    return [super defaultEntityWith:YGEntityTypeAccount currency:currency counterpartyType:YYGCounterpartyTypeNone];
}

- (BOOL)isOnlyChoiceTarget {
    return [super isOnlyChoiceEntityWith:YGEntityTypeAccount];
}

- (BOOL)showTargetSum {
    return YES;
}

- (BOOL)hasSumAndCurrency:(id<YYGRowIdAndNameIdentifiable>)object {
    if([[object class] conformsToProtocol:@protocol(YYGSumAndCurrencyIdentifiable)])
        return YES;
    else
        return NO;
}

- (YGCategory *)currencyOf:(id<YYGSumAndCurrencyIdentifiable>)object {
    return [super currencyWithId:object.currencyId];
}

- (BOOL)isSourceNeedForSave {
    return YES;
}

- (BOOL)isSourceSumNotNullNeedForSave {
    return NO;
}

- (BOOL)isTargetNeedForSave {
    return YES;
}

- (BOOL)isTargetSumNotNullNeedForSave {
    return YES;
}

- (NSInteger)addOperation:(YGOperation *)operation {
    return [super addOperation:operation];
}

- (void)updateOperation:(YGOperation *)operation withNew:(YGOperation *)newOperation {
    [super updateOperation:operation withNew:newOperation];
}

- (void)removeOperation:(YGOperation *)operation {
    [super removeOperation:operation];
}

- (void)recalcBalanceWith:(YGOperation *)operation {
    [super recalcBalanceWith:operation];
}

- (id<YYGRowIdAndNameIdentifiable>)sourceOf:(YGOperation *)operation {
    return [super entityWithId:operation.sourceId type:YGEntityTypeDebt];
}

- (id<YYGRowIdAndNameIdentifiable>)targetOf:(YGOperation *)operation {
    return [super entityWithId:operation.targetId type:YGEntityTypeAccount];
}

- (NSInteger)heightForRow:(NSInteger)row inSection:(NSInteger)section {
    
    NSInteger height = 44;
    
    switch (section) {
        case 0:                 // Date
            break;
        case 1:                 // Transfer
            switch (row) {
                case 0:         // Source
                    break;
                case 1:         // Source Sum
                    height = 0;
                    break;
                case 2:         // Target
                    break;
                case 3:         // Target Sum
                    break;
                default:
                    @throw [NSException exceptionWithName:@"YYGRepaymentDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown row number." userInfo:nil];
            }
            break;
        case 2:                 // Comment
            height = 70;
            break;
        case 3:                 // Actions
            switch (row) {
                case 0:         // Delete
                    if(!self.operation)
                        height = 0;
                    break;
                case 1:         // Save & add
                    height = 0;
                    break;
                default:
                    @throw [NSException exceptionWithName:@"YYGRepaymentDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown row number." userInfo:nil];
            }
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGRepaymentDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown section number." userInfo:nil];
    }
    
    return height;
}

- (BOOL)isSelectableRowAt:(NSInteger)row inSection:(NSInteger)section {
    if(row == 0 && section == 1) // source
        return YES;
    else if(row == 2 && section == 1) // target
        return YES;
    else
        return NO;
}

- (NSString *)selectSchemeNameForRow:(NSInteger)row inSection:(NSInteger)section {
    if(row == 0 && section == 1)
        return @"YYGEntitySelectController";
    else if(row == 2 && section == 1)
        return @"YYGEntitySelectController";
    else
        return nil;
}

- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section supposedCurrency:(YGCategory *)supposedCurrency {
    if(row == 0 && section == 1) // source
        return [YYGEntitySelectViewModel viewModelWith:YGEntityTypeDebt customer:YYGEntitySelectForOperationEditSource counterpartyType:YYGCounterpartyTypeDebtor allowCurrencies:self.allowDebtCurrencies supposedCurrency:supposedCurrency];
    else if(row == 2 && section == 1) // target
        return [YYGEntitySelectViewModel viewModelWith:YGEntityTypeAccount customer:YYGEntitySelectForOperationEditTarget counterpartyType:YYGCounterpartyTypeNone allowCurrencies:self.allowDebtCurrencies supposedCurrency:supposedCurrency];
    else
        return nil;
}

- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section {
    @throw [NSException exceptionWithName:@"YYGRepaymentDebtEditViewModel selectViewModelForRow:inSection: fails." reason:@"Method can not be called." userInfo:nil];
}

- (NSString *)textSelectSource {
    return NSLocalizedString(@"OPERATION_EDIT_FORM_SELECT_SOURCE_DEBT", @"Select source debt red label");
}

- (NSString *)textSelectTarget {
    return NSLocalizedString(@"OPERATION_EDIT_FORM_SELECT_TARGET_ACCOUNT", @"Select target account red label");
}

- (BOOL)checkPiredForSameCurrency {
    return YES;
}

- (BOOL)sameSourceAndTarget {
    return NO;
}

- (BOOL)sameSourceAndTargetSum {
    return YES;
}

@end
