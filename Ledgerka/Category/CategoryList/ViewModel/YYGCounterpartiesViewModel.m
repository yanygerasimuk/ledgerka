//
//  YYGCounterpartiesViewModel.m
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCounterpartiesViewModel.h"
#import "YGCategoryManager.h"

@interface YYGCounterpartiesViewModel() {
    YYGCategorySection *p_section;
}
@end

@implementation YYGCounterpartiesViewModel

- (YGCategoryType)type {
    return YGCategoryTypeCounterparty;
}

- (NSString *)title {
    return NSLocalizedString(@"COUNTERPARTIES_VIEW_FORM_TITLE", @"Title of Counteparties form.");
}

- (NSString *)cashUpdateNotificationName {
    return @"CategoryManagerCounterpartyCacheUpdateEvent";
}

- (void)loadSection {
    YGCategoryManager *categoryManager = [YGCategoryManager sharedInstance];
    p_section = [[YYGCategorySection alloc] initWithCategories:[categoryManager categoriesByType:YGCategoryTypeCounterparty]];
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
    return NSLocalizedString(@"NO_COUNTERPARTIES_LABEL", @"No counterparties in Counterparties form.");
}

@end
