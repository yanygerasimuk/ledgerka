//
//  YYGIncomeViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGIncomeViewModel.h"

@implementation YYGIncomeViewModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"INCOME_SOURCE_EDIT_FORM_TITLE", @"Title of Income source form.");
}

- (BOOL)isActivateButtonMustBeHide {
    if(![self.categoryManager hasActiveCategoryForTypeExceptCategory:self.category]
       || [self.categoryManager isJustOneCategory:self.category])
        return YES;
    else
        return NO;
}

- (BOOL)isDeleteButtonMustBeHide {
    if([self.categoryManager hasLinkedObjectsForCategory:self.category]
    || ![self.categoryManager hasActiveCategoryForTypeExceptCategory:self.category]
       || [self.categoryManager isJustOneCategory:self.category])
        return YES;
    else
        return NO;
}

- (BOOL)letDeactivateAction {
    if([self.categoryManager hasActiveCategoryForTypeExceptCategory:self.category])
        return YES;
    else
        return NO;
}

- (BOOL)letDeleteAction {
    return ![self isDeleteButtonMustBeHide];    
}

- (NSString *)canNotDeleteReason {
    
    if([self.categoryManager hasLinkedObjectsForCategory:self.category]) {
        return NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"Message with reason that category has linked objects (operations, accounts, debts, etc.)");
    }
    else if([self.categoryManager isJustOneCategory:self.category]) {
        return NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ONLY_ONE_CATEGORY_EXISTS_FOR_TYPE_MESSAGE", @"Message with reason that category is only one for type and can not be deleted.");
    }
    else if(![self.categoryManager hasActiveCategoryForTypeExceptCategory:self.category]) {
        return NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ABSENT_ANOTHER_ACTIVE_CATEGORY_FOR_TYPE_MESSAGE", @"Message with reason that category is only one active for type and another is not exists.");
    }
    else
        return nil;
}

- (void)remove:(YGCategory *)category {
    [super remove:category];
}

- (void)add:(YGCategory *)category {
    [super add:category];
}

- (void)activate:(YGCategory *)category {
    [super activate:category];
}

- (void)deactivate:(YGCategory *)category {
    [super deactivate:category];
}

- (void)update:(YGCategory *)category {
    [super update:category];
}

@end
