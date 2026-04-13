//
//  YYGCategoryRow.m
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryRow.h"
#import "YGCategory.h"
#import "YGCategoryManager.h"

@interface YYGCategoryRow ()
@end

@implementation YYGCategoryRow

- (instancetype)initWithCategory:(YGCategory *)category nestedLevel:(NSInteger)nestedLevel {
    self = [super init];
    if(self){
        _category = [category copy];
        _name = _category.name;
        
        if(_category.type == YGCategoryTypeCurrency){
            _symbol = [category shorterName];
        }
        
        _nestedLevel  = nestedLevel;
    }
    return self;
}

@end
