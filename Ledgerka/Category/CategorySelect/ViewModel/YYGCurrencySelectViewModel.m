//
//  YYGCurrencySelectViewModel.m
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCurrencySelectViewModel.h"

@implementation YYGCurrencySelectViewModel

- (instancetype)init {
    self = [super init];
    if(self) {
        ;
    }
    return self;
}

- (NSArray <YGCategory *> *)activeCategories {
    return [self.categoryManager categoriesByType:YGCategoryTypeCurrency onlyActive:YES];
}

- (NSArray <YGCategory *> *)activeCategoriesExcept:(YGCategory *)category {
    return [self.categoryManager categoriesByType:YGCategoryTypeCurrency onlyActive:YES exceptCategory:category];
}

- (BOOL)showDetailText {
    return YES;
}

- (NSString *)textOf:(YGCategory *)category {
    return category.name;
    
}

- (NSString *)detailTextOf:(YGCategory *)category {
    return [category shorterName];
}

- (NSString *)unwindSegueName {
    return @"unwindFromCurrencySelectToEntityEdit";
}

- (NSString *)title {
    return NSLocalizedString(@"CURRENCY_CHOICE_FORM_TITLE", @"Title of Currency choice form.");
}

@end
