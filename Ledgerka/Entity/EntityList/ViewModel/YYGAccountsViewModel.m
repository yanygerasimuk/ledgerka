//
//  YYGAccountsViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGAccountsViewModel.h"

@implementation YYGAccountsViewModel

- (NSString *)title {
    return NSLocalizedString(@"ACCOUNTS_VIEW_FORM_TITLE", @"Title of Accounts form");
}

- (NSString *)noDataMessage {
    return NSLocalizedString(@"NO_ACCOUNTS_LABEL", @"No accounts in Accounts form.");
}

- (NSString *)currencyNameWithId:(NSInteger)currencyId {
    return [super currencyNameWithId:currencyId];
}

- (BOOL)isEnoughConditionsWithFeedback:(void(^)(NSString *message))feedback {
    NSString *message;
    if(![super hasActiveCategoryWith:YGCategoryTypeCurrency])
        message = NSLocalizedString(@"ACCOUNTS_VIEW_MODEL_NEEDS_ACTIVE_CURRENCY", @"To add new account needs active currency");
    
    if(message) {
        message = [NSString stringWithFormat:@"%@\n%@\n\n%@", NSLocalizedString(@"ACCOUNTS_VIEW_MODEL_NEEDS_INTRO", @"To add new account required:"), message, NSLocalizedString(@"ACCOUNTS_VIEW_MODEL_NEEDS_WHERE_TODO", @"To add new account info about where")];
        feedback(message);
        return NO;
    } else {
        feedback(nil);
        return YES;
    }
}

- (BOOL)showDebtType {
    return NO;
}

@end
