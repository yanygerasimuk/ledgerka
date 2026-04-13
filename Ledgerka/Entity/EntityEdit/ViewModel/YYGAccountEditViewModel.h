//
//  YYGAccountEditViewModel.h
//  Ledger
//
//  Created by Ян on 24.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntityEditViewModel.h"

@interface YYGAccountEditViewModel : YYGEntityEditViewModel <YYGEntityEditViewModelable>

- (instancetype)init;

- (NSString *)title;
- (YGCategory *)defaultCurrency;
- (YGCategory *)currencyOf:(YGEntity *)entity;
- (void)remove:(YGEntity *)entity;
- (void)activate:(YGEntity *)entity;
- (void)deactivate:(YGEntity *)entity;
- (void)add:(YGEntity *)entity;
- (void)update:(YGEntity *)entity;

- (BOOL)isExistLinkedOperationsWith:(YGEntity *)entity;
- (BOOL)isExistDuplicateOf:(YGEntity *)entity;
- (NSInteger)countOfActiveCategoriesOf:(YGCategoryType)type;

- (BOOL)showCounterpartyAndTypeSection;
- (BOOL)showDefaultSection;

- (BOOL)hasCounterparty;
- (YGCategory *)counterpartyOf:(YGEntity *)entity;
- (YGCategory *)defaultCounterparty;

- (BOOL)isOnlyOneActive:(YGCategory *)category;

- (BOOL)canDelete;
- (BOOL)canChangeCounterparty;
- (BOOL)canChangeCounterpartyType;
- (BOOL)canChangeCurrency;

- (BOOL)hasAccountWithCurrencyId:(NSInteger)currencyId;

- (NSString *)textLabelIsDefault;
- (NSString *)textSegmentedDebtor;
- (NSString *)textSegmentedCreditor;
@end
