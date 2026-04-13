//
//  YGCategoryManager.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"

@interface YGCategoryManager : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary <NSString *, NSMutableArray <YGCategory *>*> *categories;

+ (instancetype)sharedInstance;

- (void)addCategory:(YGCategory *)category;
- (YGCategory *)categoryById:(NSInteger)categoryId type:(YGCategoryType)type;
- (void)deactivateCategory:(YGCategory *)category;
- (void)activateCategory:(YGCategory *)category;
- (void)removeCategory:(YGCategory *)category;

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive exceptCategory:(YGCategory *)exceptCategory;
- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive;
- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type;

- (YGCategory *)categoryAttachedForType:(YGCategoryType)type;
- (YGCategory *)categoryOnTopForType:(YGCategoryType)type;
- (void)updateCategory:(YGCategory *)category;
- (void)setOnlyOneDefaultCategory:(YGCategory *)category;

- (BOOL)hasLinkedObjectsForCategory:(YGCategory *)category;
- (BOOL)hasChildObjectForCategory:(YGCategory *)category;
- (BOOL)hasChildObjectActiveForCategory:(YGCategory *)category;
- (BOOL)isJustOneCategory:(YGCategory *)category;
- (BOOL)hasActiveCategoryForTypeExceptCategory:(YGCategory *)category;
- (BOOL)hasLinkedActiveEntityForCurrency:(YGCategory *)category;

- (BOOL)isExistActiveCategoryOfType:(YGCategoryType)type;
- (NSInteger)countOfActiveCategoriesForType:(YGCategoryType)type;

- (YGCategory *)defaultCategoryOfType:(YGCategoryType)type;

@end
