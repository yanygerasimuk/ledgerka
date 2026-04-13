//
//  YYGDebtEditViewModel.m
//  Ledger
//
//  Created by Ян on 24.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtEditViewModel.h"

@implementation YYGDebtEditViewModel

- (instancetype)init {
    self = [super init];
    if(self){
        ;
    }
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"DEBT_EDIT_FORM_TITLE", @"Title of Debt view/edit form.");
}

- (YGCategory *)defaultCurrency {
    return [super defaultCurrency];
}

- (YGCategory *)currencyOf:(YGEntity *)entity {
    return [super currencyOf:entity];
}

- (void)remove:(YGEntity *)entity {
    [super remove:entity];
}

- (void)activate:(YGEntity *)entity {
    [super activate:entity];
}

- (void)deactivate:(YGEntity *)entity {
    [super deactivate:entity];
}

- (void)add:(YGEntity *)entity {
    [super add:entity];
}

- (void)update:(YGEntity *)entity {
    [super update:entity];
}

- (BOOL)isExistLinkedOperationsWith:(YGEntity *)entity {
    return [super isExistLinkedOperationsWith:entity];
}

- (BOOL)isExistDuplicateOf:(YGEntity *)entity {
    return [super isExistDuplicateOf:entity];
}

- (NSInteger)countOfActiveCategoriesOf:(YGCategoryType)type {
    return [super countOfActiveCategoriesOf:type];
}

- (BOOL)showCounterpartyAndTypeSection {
    return YES;
}

- (BOOL)showDefaultSection {
    return YES;
}

- (BOOL)hasCounterparty {
    return YES;
}

- (YGCategory *)counterpartyOf:(YGEntity *)entity {
    return [super counterpartyOf:entity];
}

- (YGCategory *)defaultCounterparty {
    return [super defaultCounterparty];
}

- (BOOL)isOnlyOneActive:(YGCategory *)category {
    return [super isOnlyOneActive:category];
}

- (BOOL)canDelete {
    return [super canDelete];
}

- (BOOL)canChangeCounterparty {
    return [super canChangeCounterparty];
}

- (BOOL)canChangeCounterpartyType {
    return [super canChangeCounterpartyType];
}

- (BOOL)canChangeCurrency {
    return [super canChangeCurrency];
}

- (BOOL)hasAccountWithCurrencyId:(NSInteger)currencyId {
    return [super hasAccountWithCurrencyId:currencyId];
}

- (NSString *)textLabelIsDefault {
    return NSLocalizedString(@"ENTITY_EDIT_FORM_IS_DEFAULT_DEBT_LABEL", @"Is default debt label");
}

- (NSString *)textSegmentedDebtor {
    return NSLocalizedString(@"ENTITY_EDIT_FORM_DEBTOR_SEGMENTED", @"Title of debtor in segmented");
}

- (NSString *)textSegmentedCreditor {
    return NSLocalizedString(@"ENTITY_EDIT_FORM_CREDITOR_SEGMENTED", @"Title of creditor in segmented");
}

@end
