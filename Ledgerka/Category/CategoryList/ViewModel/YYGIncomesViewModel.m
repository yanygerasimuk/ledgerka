//
//  YYGIncomesViewModel.m
//  Ledger
//
//  Created by Ян on 25.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGIncomesViewModel.h"
#import "YGCategoryManager.h"

@interface YYGIncomesViewModel() {
    YYGCategorySection *p_section;
}
@end

@implementation YYGIncomesViewModel

- (YGCategoryType)type {
    return YGCategoryTypeIncome;
}

- (NSString *)title {
    return NSLocalizedString(@"INCOME_SOURCES_VIEW_FORM_TITLE", @"Title of Income sources form.");
}

- (NSString *)cashUpdateNotificationName {
    return @"CategoryManagerIncomeCacheUpdateEvent";
}

- (void)loadSection {
    YGCategoryManager *categoryManager = [YGCategoryManager sharedInstance];
    p_section = [[YYGCategorySection alloc] initWithCategories:[categoryManager categoriesByType:YGCategoryTypeIncome]];
}

- (YYGCategorySection *)section {
    return p_section;
}

- (NSString *)textLeftOf:(YYGCategoryRow *)row {
    return row.name;
}

- (NSString *)textRightOf:(YYGCategoryRow *)row {
    return nil;
}

- (NSString *)viewControllerStoryboardName {
    return @"CategoryDefaultEditScene";
}

- (NSString *)noDataMessage {
    return NSLocalizedString(@"NO_INCOME_SOURCES_LABEL", @"No income sources in Income sources form.");
}

@end
