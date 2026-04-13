//
//  YYGCategoryViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryViewModel.h"
#import "YYGCounterpartyViewModel.h"
#import "YYGExpenseViewModel.h"
#import "YYGIncomeViewModel.h"
#import "YYGCurrencyViewModel.h"

@implementation YYGCategoryViewModel

+ (id<YYGCategoryViewModelable>)viewModelWith:(YGCategoryType)type {
    id<YYGCategoryViewModelable> viewModel;
    switch(type){
        case YGCategoryTypeCurrency:
            viewModel = [[YYGCurrencyViewModel alloc] init];
            viewModel.type = YGCategoryTypeCurrency;
            break;
        case YGCategoryTypeIncome:
            viewModel = [[YYGIncomeViewModel alloc] init];
            viewModel.type = YGCategoryTypeIncome;
            break;
        case YGCategoryTypeExpense:
            viewModel = [[YYGExpenseViewModel alloc] init];
            viewModel.type = YGCategoryTypeExpense;
            break;
        case YGCategoryTypeCounterparty:
            viewModel = [[YYGCounterpartyViewModel alloc] init];
            viewModel.type = YGCategoryTypeCounterparty;
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGCategoryViewModel.viewModelWith: fails" reason:@"Unknown category type" userInfo:nil];
    }
    return viewModel;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _categoryManager = [YGCategoryManager sharedInstance];
    }
    return self;
}

- (NSString *)title {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.title fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (BOOL)isActivateButtonMustBeHide {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.isActivateButtonMustBeHide fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (BOOL)isDeleteButtonMustBeHide {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.isActivateButtonMustBeHide fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (BOOL)letDeactivateAction {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.letDeactivateAction fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (BOOL)letDeleteAction {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.letDeleteAction fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (NSString *)canNotDeleteReason {
    @throw [NSException exceptionWithName:@"YYGCategoryViewModel.canNotDeleteReason fails" reason:@"Method must be overrided in subclass." userInfo:nil];
}

- (void)remove:(YGCategory *)category {
    [self.categoryManager removeCategory:category];
}

- (void)add:(YGCategory *)category {
    [self.categoryManager addCategory:category];
}

- (void)activate:(YGCategory *)category {
    [self.categoryManager activateCategory:category];
}

- (void)deactivate:(YGCategory *)category {
    [self.categoryManager deactivateCategory:category];
}

- (void)update:(YGCategory *)category {
    [self.categoryManager updateCategory:category];
}

@end
