//
//  YYGCategorySelectViewModel.h
//  Ledger
//
//  Created by Ян on 02.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"
#import "YGCategoryManager.h"

@protocol YYGCategorySelectViewModelable
@property (nonatomic, strong) YGCategory *source;
@property (nonatomic, strong) YGCategory *target;
- (NSArray <YGCategory *> *)activeCategories;
- (NSArray <YGCategory *> *)activeCategoriesExcept:(YGCategory *)category;
- (BOOL)showDetailText;
- (NSString *)textOf:(YGCategory *)category;
- (NSString *)detailTextOf:(YGCategory *)category;
- (NSString *)unwindSegueName;
- (NSString *)title;
@end

@interface YYGCategorySelectViewModel : NSObject

+ (id<YYGCategorySelectViewModelable>)viewModelWith:(YGCategoryType)type;

@property (nonatomic, strong) YGCategoryManager *categoryManager;
@property (nonatomic, strong) YGCategory *source;
@property (nonatomic, strong) YGCategory *target;

- (instancetype)init;
@end
