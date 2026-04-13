//
//  YYGCategorySection.h
//  Ledger
//
//  Created by Ян on 15/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YGCategory;
@class YYGCategoryRow;

@interface YYGCategorySection : NSObject

@property (strong, nonatomic) NSArray <YGCategory *> *categories;
@property (strong, nonatomic) NSArray <YYGCategoryRow *> *rows;

- (instancetype)initWithCategories:(NSArray <YGCategory *>*)categories;
@end
