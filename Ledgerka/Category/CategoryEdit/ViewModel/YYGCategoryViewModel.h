//
//  YYGCategoryViewModel.h
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"
#import "YGCategoryManager.h"

@protocol YYGCategoryViewModelable
@property (assign, nonatomic) BOOL isNew;
@property (assign, nonatomic) YGCategoryType type;
@property (strong, nonatomic) YGCategory *category;
- (NSString *)title;
- (BOOL)isActivateButtonMustBeHide;
- (BOOL)isDeleteButtonMustBeHide;
- (BOOL)letDeactivateAction;
- (BOOL)letDeleteAction;
- (NSString *)canNotDeleteReason;
- (void)add:(YGCategory *)category;
- (void)remove:(YGCategory *)category;
- (void)activate:(YGCategory *)category;
- (void)deactivate:(YGCategory *)category;
- (void)update:(YGCategory *)category;
@end

@protocol YYGCategoryViewControllerViewModelable
@property (strong, nonatomic) id<YYGCategoryViewModelable> viewModel;
@end

@interface YYGCategoryViewModel : NSObject <YYGCategoryViewModelable>

+ (id<YYGCategoryViewModelable>)viewModelWith:(YGCategoryType)type;

@property (strong, nonatomic, readonly) YGCategoryManager *categoryManager;
@property (assign, nonatomic) BOOL isNew;
@property (assign, nonatomic) YGCategoryType type;
@property (strong, nonatomic) YGCategory *category;

- (instancetype)init;

- (void)add:(YGCategory *)category;
- (void)remove:(YGCategory *)category;
- (void)activate:(YGCategory *)category;
- (void)deactivate:(YGCategory *)category;
- (void)update:(YGCategory *)category;

@end
