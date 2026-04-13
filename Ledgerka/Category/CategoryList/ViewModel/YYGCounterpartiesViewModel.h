//
//  YYGCounterpartiesViewModel.h
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoriesViewModel.h"

@interface YYGCounterpartiesViewModel : YYGCategoriesViewModel <YYGCategoriesViewModelable>
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
