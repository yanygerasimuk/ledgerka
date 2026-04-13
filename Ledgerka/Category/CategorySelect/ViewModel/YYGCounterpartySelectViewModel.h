//
//  YYGCounterpartySelectViewModel.h
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategorySelectViewModel.h"

@interface YYGCounterpartySelectViewModel : YYGCategorySelectViewModel <YYGCategorySelectViewModelable>
- (instancetype)init;
- (NSArray <YGCategory *> *)activeCategories;
- (NSArray <YGCategory *> *)activeCategoriesExcept:(YGCategory *)category;
- (BOOL)showDetailText;
- (NSString *)textOf:(YGCategory *)category;
- (NSString *)detailTextOf:(YGCategory *)category;
- (NSString *)unwindSegueName;
- (NSString *)title;
@end
