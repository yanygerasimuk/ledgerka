//
//  YYGCategoriesViewModel.h
//  Ledger
//
//  Created by Ян on 25.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"
#import "YYGCategorySection.h"
#import "YYGCategoryRow.h"

@protocol YYGCategoriesViewModelable
- (YGCategoryType)type;
- (NSString *)title;
- (NSString *)cashUpdateNotificationName;
- (void)loadSection;
- (YYGCategorySection *)section;
- (NSString *)textLeftOf:(YYGCategoryRow *)row;
- (NSString *)textRightOf:(YYGCategoryRow *)row;
- (NSString *)viewControllerStoryboardName;
- (NSString *)noDataMessage;
@end

@interface YYGCategoriesViewModel : NSObject
+ (id<YYGCategoriesViewModelable>)viewModelWith:(YGCategoryType)type;
@end
