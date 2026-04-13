//
//  YYGAccountEditViewModel.m
//  Ledger
//
//  Created by Ян on 24.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGAccountEditViewModel.h"

@implementation YYGAccountEditViewModel

- (instancetype)init {
    self = [super init];
    if(self){
        ;
    }
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"ACCOUNT_EDIT_FORM_TITLE", @"Title of Account view/edit form.");
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
    return NO;
}

- (BOOL)showDefaultSection {
    return YES;
}

- (BOOL)hasCounterparty {
    return NO;
}

- (YGCategory *)counterpartyOf:(YGEntity *)entity {
    return nil;
}

- (YGCategory *)defaultCounterparty {
    return nil;
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
    return NO;
}

- (NSString *)textLabelIsDefault {
    return NSLocalizedString(@"ENTITY_EDIT_FORM_IS_DEFAULT_ACCOUNT_LABEL", @"Is default account label");
}

- (NSString *)textSegmentedDebtor {
    return nil;
}

- (NSString *)textSegmentedCreditor {
    return nil;
}

@end
