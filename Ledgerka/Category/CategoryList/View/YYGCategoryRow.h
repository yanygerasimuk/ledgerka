//
//  YYGCategoryRow.h
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YGCategory;

@interface YYGCategoryRow : NSObject

@property (strong, nonatomic) YGCategory *category;

/// cache name, may be with indent
@property (strong, nonatomic) NSString *name;

/// cache symbol, if they exists
@property (strong, nonatomic) NSString *symbol;

/// nested level of category
@property (assign, nonatomic) NSInteger nestedLevel;

- (instancetype)initWithCategory:(YGCategory *)category nestedLevel:(NSInteger)nestedLevel;

@end
