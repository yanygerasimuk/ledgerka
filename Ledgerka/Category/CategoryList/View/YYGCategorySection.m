//
//  YYGCategorySection.m
//  Ledger
//
//  Created by Ян on 15/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategorySection.h"
#import "YYGCategoryRow.h"
#import "YGCategory.h"

@interface YYGCategorySection () {
    NSArray <YGCategory *> *p_categories;
}
@end

@implementation YYGCategorySection

- (instancetype)initWithCategories:(NSArray <YGCategory *>*)categories {
    self = [super init];
    if(self){
        p_categories = categories;
        _rows = [self rowsFromCategories:p_categories];
    }
    return self;
}

- (NSArray <YYGCategoryRow *>*)rowsFromCategories:(NSArray <YGCategory *>*)categories {
    
    NSArray *rows = nil;
    
    // if categories is tree or plane
    NSPredicate *treePredicate = [NSPredicate predicateWithFormat:@"parentId > 0"];
    
    if([[p_categories filteredArrayUsingPredicate:treePredicate] count] > 0){
        //NSLog(@"p_categories is tree");
        rows = [self rowsTreeFromCategories:p_categories];
    }
    else{
        //NSLog(@"p_categories is plane");
        rows = [self rowsPlaneFromCategories:p_categories];
    }
    return rows;
}

- (NSArray *)rowsPlaneFromCategories:(NSArray *)categories {
    
    NSMutableArray *result = [NSMutableArray array];
    
    for(YGCategory *category in categories){
        
        YYGCategoryRow *row = [[YYGCategoryRow alloc] initWithCategory:category nestedLevel:0];
        [result addObject:row];
    }
    
    return result;
}

- (NSArray *)rowsTreeFromCategories: (NSArray *)categories {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSPredicate *rootPredicate = [NSPredicate predicateWithFormat:@"parentId < 1"];
    
    for(YGCategory *category in [categories filteredArrayUsingPredicate:rootPredicate]){
        
        //NSLog(@"root category: %@", category.name);
        
        [self includeCategory:category fromCategories:categories toTreeRows:result];
    }
    
    return result;
}

- (void)includeCategory:(YGCategory *)category fromCategories:(NSArray <YGCategory *>*)categories toTreeRows:(NSMutableArray <YYGCategoryRow *>*)result {
    
    //NSLog(@"includeCategory:fromCategories:toTreeRows:...");
    
    static NSInteger nestedLevel;
    
    // check if category is root, to init nested level
    if(category.parentId < 1)
        nestedLevel = 0;
    
    YYGCategoryRow *row = [[YYGCategoryRow alloc] initWithCategory:category nestedLevel:nestedLevel];
    [result addObject:row];
    //NSLog(@"category: %@, nestedLevel: %ld, added as a row", category.name, nestedLevel);
    
    // check if category have child
    NSPredicate *hasChildPredicate = [NSPredicate predicateWithFormat:@"parentId = %ld", category.rowId];
    NSArray *childCategories = [categories filteredArrayUsingPredicate:hasChildPredicate];
    
    if([childCategories count] > 0){
        
        //NSLog(@"category: %@ has a %ld childs", category.name, [childCategories count]);
        
        nestedLevel += 1;
        
        for(YGCategory *childCategory in childCategories){
            
            [self includeCategory:childCategory fromCategories:categories toTreeRows:result];
        }
        
        nestedLevel -= 1;
    }
}

@end
