//
//  YYGCategorySelectViewModel.m
//  Ledger
//
//  Created by Ян on 02.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategorySelectViewModel.h"
#import "YYGCounterpartySelectViewModel.h"
#import "YYGCurrencySelectViewModel.h"

@implementation YYGCategorySelectViewModel

+ (id<YYGCategorySelectViewModelable>)viewModelWith:(YGCategoryType)type {
    
    switch(type) {
        case YGCategoryTypeCounterparty:
            return [[YYGCounterpartySelectViewModel alloc] init];
        case YGCategoryTypeCurrency:
            return [[YYGCurrencySelectViewModel alloc] init];
        default:
            @throw [NSException exceptionWithName:@"Unknown entity type" reason:@"YYGEntityEditViewModel.viewModelWith: failed. Unknown entity type" userInfo:nil];
            return nil; // ?
    }
}

- (instancetype)init {
    self = [super init];
    if(self) {
        //
    }
    return self;
}

- (YGCategoryManager *)categoryManager {
    if(!_categoryManager)
        _categoryManager = [YGCategoryManager sharedInstance];
    return _categoryManager;
}

@end
