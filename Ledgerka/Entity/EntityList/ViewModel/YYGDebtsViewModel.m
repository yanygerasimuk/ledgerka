//
//  YYGDebtsViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtsViewModel.h"

@implementation YYGDebtsViewModel

- (NSString *)title {
    return NSLocalizedString(@"DEBTS_VIEW_FORM_TITLE", @"Title of Debts form");
}

- (NSString *)noDataMessage {
    return NSLocalizedString(@"NO_DEBTS_LABEL", @"No debts in Debts form.");
}

- (NSString *)currencyNameWithId:(NSInteger)currencyId {
    return [super currencyNameWithId:currencyId];
}

- (BOOL) isEnoughConditionsWithFeedback:(void(^)(NSString *message))feedback {
    NSString *message;
    if(![super hasActiveCategoryWith:YGCategoryTypeCurrency])
        message = NSLocalizedString(@"DEBTS_VIEW_MODEL_NEEDS_ACTIVE_CURRENCY", @"To add new debts needs active currency");
    if(![super hasActiveCategoryWith:YGCategoryTypeCounterparty])
        message = message ? [NSString stringWithFormat:@"%@,\n%@", message, NSLocalizedString(@"DEBTS_VIEW_MODEL_NEEDS_ACTIVE_COUNTERPARTY", @"To add new debts needs active counterparty")] : NSLocalizedString(@"DEBTS_VIEW_MODEL_NEEDS_ACTIVE_COUNTERPARTY", @"To add new debts needs active counterparty");
    
    if(message) {
        message = [NSString stringWithFormat:@"%@\n%@\n\n%@", NSLocalizedString(@"DEBTS_VIEW_MODEL_NEEDS_INTRO", @"To add new debts needs intro"), message, NSLocalizedString(@"DEBTS_VIEW_MODEL_NEEDS_WHERE_TODO", @"To add new debts info about where")];
        feedback(message);
        return NO;
    } else {
        feedback(nil);
        return YES;
    }
}

- (BOOL)showDebtType {
    return YES;
}

@end
