//
//  YYGSetDebtViewModel.m
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGSetDebtViewModel.h"
#import "YYGEntitySelectViewModel.h"

@implementation YYGSetDebtViewModel

#pragma mark - User interface

- (NSString *)title {
    return NSLocalizedString(@"OPERATION_EDIT_FORM_SET_DEBT_TITLE", @"Title for set debt operation");
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
        @throw [NSException exceptionWithName:@"YYGSetDebtViewModel.numberOfRowsInSection: fails." reason:@"Unknown section number." userInfo:nil];
    return rows;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch(section) {
        case 0:
            break;
        case 1:
            title = NSLocalizedString(@"OPERATION_EDIT_FORM_DEBT_SIZE_SECTION", @"Section title for set debt in operation edit form");
            break;
        case 2:
        case 3:
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel.titleForHeaderInSection: fails." reason:@"Unknown section number." userInfo:nil];
    }
    return title;
}

- (BOOL)showSource {
    return NO;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultSource {
    return nil;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultSourceWithCurrency:(YGCategory *)currency {
    @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel defaultSourceWithCurrency: fails." reason:@"Method can not be called." userInfo:nil];
}

- (BOOL)isOnlyChoiceSource {
    return NO;
}

- (BOOL)showSourceSum {
    return NO;
}

- (BOOL)showTarget {
    return YES;
}

- (id<YYGRowIdAndNameIdentifiable>)defaultTarget {
    return [super defaultEntityWith:YGEntityTypeDebt];
}

- (id<YYGRowIdAndNameIdentifiable>)defaultTargetWithCurrency:(YGCategory *)currency {
    @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel defaultTargetWithCurrency: fails." reason:@"Method can not be called." userInfo:nil];
}

- (BOOL)isOnlyChoiceTarget {
    return [super isOnlyChoiceEntityWith:YGEntityTypeDebt counterpartyType:YYGCounterpartyTypeNone];
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
    return NO;
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
    return nil;
}

- (id<YYGRowIdAndNameIdentifiable>)targetOf:(YGOperation *)operation {
    return [super entityWithId:operation.targetId type:YGEntityTypeDebt];
}

- (NSInteger)heightForRow:(NSInteger)row inSection:(NSInteger)section {

    NSInteger height = 44;

    switch (section) {
        case 0:                 // Date
            break;
        case 1:                 // Transfer
            switch (row) {
                case 0:         // Source
                    height = 0;
                    break;
                case 1:         // Source Sum
                    height = 0;
                    break;
                case 2:         // Target
                    break;
                case 3:         // Target Sum
                    break;
                default:
                    @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown row number." userInfo:nil];
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
                    @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown row number." userInfo:nil];
            }
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel heightForRow:inSection: fails." reason:@"Unknown section number." userInfo:nil];
    }
    
    return height;
}

- (BOOL)isSelectableRowAt:(NSInteger)row inSection:(NSInteger)section {
    if(row == 2 && section == 1) // target
        return YES;
    else
        return NO;
}

- (NSString *)selectSchemeNameForRow:(NSInteger)row inSection:(NSInteger)section {
    if(row == 2 && section == 1)
        return @"YYGEntitySelectController";
    else
        return nil;
}

- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section {
    if(row == 2 && section) // target
        return [YYGEntitySelectViewModel viewModelWith:YGEntityTypeDebt customer:YYGEntitySelectForOperationEditTarget counterpartyType:YYGCounterpartyTypeNone];
    else
        return nil;
}

- (id)selectViewModelForRow:(NSInteger)row inSection:(NSInteger)section supposedCurrency:(YGCategory *)supposedCurrency {
    @throw [NSException exceptionWithName:@"YYGSetDebtEditViewModel selectViewModelForRow:inSection:supposedCurrency:: fails." reason:@"Method can not be called." userInfo:nil];
}

- (NSString *)textSelectSource {
    return nil;
}

- (NSString *)textSelectTarget {
    return NSLocalizedString(@"OPERATION_EDIT_FORM_SELECT_TARGET_DEBT", @"Select target debt red label");
}

- (BOOL)checkPiredForSameCurrency {
    return NO;
}

- (BOOL)sameSourceAndTarget {
    return YES;
}

- (BOOL)sameSourceAndTargetSum {
    return YES;
}

@end
