//
//  YYGCurrenciesViewModel.m
//  Ledger
//
//  Created by Ян on 25.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCurrenciesViewModel.h"
#import "YGCategoryManager.h"

@interface YYGCurrenciesViewModel() {
    YYGCategorySection *p_section;
}
@end

@implementation YYGCurrenciesViewModel

- (YGCategoryType)type {
    return YGCategoryTypeCurrency;
}

- (NSString *)title {
    return NSLocalizedString(@"CURRENCIES_VIEW_FORM_TITLE", @"Title of Currencies form");
}

- (NSString *)cashUpdateNotificationName {
    return @"CategoryManagerCurrencyCacheUpdateEvent";
}

- (void)loadSection {
    YGCategoryManager *categoryManager = [YGCategoryManager sharedInstance];
    p_section = [[YYGCategorySection alloc] initWithCategories:[categoryManager categoriesByType:YGCategoryTypeCurrency]];
}

- (YYGCategorySection *)section {
    return p_section;
}

- (NSString *)textLeftOf:(YYGCategoryRow *)row {
    return row.name;
}

- (NSString *)textRightOf:(YYGCategoryRow *)row {
    return [row.category shorterName];
}

- (NSString *)viewControllerStoryboardName {
    return @"CurrencyDetailScene";
}

- (NSString *)noDataMessage {
    return NSLocalizedString(@"NO_CURRENCIES_LABEL", @"No currencies in Currencies form.");
}

@end
