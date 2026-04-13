//
//  YYGCounterpartyViewModel.m
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCounterpartyViewModel.h"

@implementation YYGCounterpartyViewModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"COUNTERPARTY_EDIT_FORM_TITLE", @"Title of Counterparty view/edit form.");
}

- (BOOL)isActivateButtonMustBeHide {
    return NO;
}

- (BOOL)isDeleteButtonMustBeHide {
    if([self.categoryManager hasLinkedObjectsForCategory:self.category])
        return YES;
    else
        return NO;
}

- (BOOL)letDeactivateAction {
    return YES;
}

- (BOOL)letDeleteAction {
    return ![self isDeleteButtonMustBeHide];
}

- (NSString *)canNotDeleteReason {
    
    if([self.categoryManager hasLinkedObjectsForCategory:self.category]) {
        return NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"Message with reason that category has linked objects (operations, accounts, debts, etc.)");
    } else
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
