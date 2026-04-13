//
//  YYGExpensesViewModel.m
//  Ledger
//
//  Created by Ян on 25.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGExpensesViewModel.h"
#import "YGCategoryManager.h"

@interface YYGExpensesViewModel() {
    YYGCategorySection *p_section;
}
@end

@implementation YYGExpensesViewModel

- (YGCategoryType)type {
    return YGCategoryTypeExpense;
}

- (NSString *)title {
    return NSLocalizedString(@"EXPENSE_CATEGORIES_VIEW_FORM_TITLE", @"Title of Expense categories form.");
}

- (NSString *)cashUpdateNotificationName {
    return @"CategoryManagerExpenseCacheUpdateEvent";
}

- (void)loadSection {
    YGCategoryManager *categoryManager = [YGCategoryManager sharedInstance];
    p_section = [[YYGCategorySection alloc] initWithCategories:[categoryManager categoriesByType:YGCategoryTypeExpense]];
}

- (YYGCategorySection *)section {
    return p_section;
}

- (NSString *)textLeftOf:(YYGCategoryRow *)row {
    NSString *indent = @"";
    for(NSInteger i = 0; i < row.nestedLevel; i++) {
        indent = [NSString stringWithFormat:@"\t%@", indent];
    }
    return [NSString stringWithFormat:@"%@%@", indent, row.name];
}

- (NSString *)textRightOf:(YYGCategoryRow *)row {
    return nil;
}

- (NSString *)viewControllerStoryboardName {
    return @"ExpenseCategoryDetailScene";
}

- (NSString *)noDataMessage {
    return NSLocalizedString(@"NO_EXPENSE_CATEGORIES_LABEL", @"No Expense categories in ExpenseCategories form.");
}

@end
