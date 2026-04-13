//
//  YYGCounterpartySelectViewModel.m
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCounterpartySelectViewModel.h"

@implementation YYGCounterpartySelectViewModel

- (instancetype)init {
    self = [super init];
    if(self) {
        ;
    }
    return self;
}

- (NSArray <YGCategory *> *)activeCategories {
    return [self.categoryManager categoriesByType:YGCategoryTypeCounterparty onlyActive:YES];
}

- (NSArray <YGCategory *> *)activeCategoriesExcept:(YGCategory *)category {
    return [self.categoryManager categoriesByType:YGCategoryTypeCounterparty onlyActive:YES exceptCategory:category];
}

- (BOOL)showDetailText {
    return NO;
}

- (NSString *)textOf:(YGCategory *)category {
    return category.name;
    
}

- (NSString *)detailTextOf:(YGCategory *)category {
    return nil;
}

- (NSString *)unwindSegueName {
    return @"unwindFromCounterpartySelectToEntityEdit";
}

- (NSString *)title {
    return NSLocalizedString(@"COUNTERPARTY_CHOICE_FORM_TITLE", @"Title of Counterparty choice form.");
}

@end
