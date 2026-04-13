//
//  YYGCategoriesViewModel.m
//  Ledger
//
//  Created by Ян on 25.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoriesViewModel.h"
#import "YYGCurrenciesViewModel.h"
#import "YYGIncomesViewModel.h"
#import "YYGExpensesViewModel.h"
#import "YYGCounterpartiesViewModel.h"

@implementation YYGCategoriesViewModel

+ (id<YYGCategoriesViewModelable>)viewModelWith:(YGCategoryType)type {
    switch(type){
        case YGCategoryTypeCurrency:
            return [[YYGCurrenciesViewModel alloc] init];
        case YGCategoryTypeIncome:
            return [[YYGIncomesViewModel alloc] init];
        case YGCategoryTypeExpense:
            return [[YYGExpensesViewModel alloc] init];
        case YGCategoryTypeCounterparty:
            return [[YYGCounterpartiesViewModel alloc] init];
        default:
            @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.viewModelWith: fails" reason:@"Unknown category type" userInfo:nil];
            return nil; // ?
    }
}

- (YGCategoryType)type {
        @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.type fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)title {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.title fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)cashUpdateNotificationName {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.cashUpdateNotificationName fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (void)loadSection {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.loadSection fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (YYGCategorySection *)section {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.section fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)textLeftOf:(YYGCategoryRow *)row {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.textLeftOf: fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)textRightOf:(YYGCategoryRow *)row {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.textRightOf: fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)viewControllerStoryboardName {
    @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.viewControllerStoryboardName fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)noDataMessage {
        @throw [NSException exceptionWithName:@"YYGCategoriesViewModel.noDataMessage fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

@end
