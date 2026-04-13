//
//  YGCategoryManager.m
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategoryManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGOperation.h"

@interface YGCategoryManager (){
    YGSQLite *_sqlite;
}
- (YGCategory *)categoryBySqlQuery:(NSString *)sqlQuery;
@end

@implementation YGCategoryManager

@synthesize categories = _categories;

#pragma mark - Singleton, init & accessors

+ (instancetype)sharedInstance{
    static YGCategoryManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGCategoryManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    
    self = [super init];
    if(self){
        _sqlite = [YGSQLite sharedInstance];
        _categories = [[NSMutableDictionary alloc] init];
        [self getCategoriesForCache];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(getCategoriesForCache)
                       name:@"DatabaseRestoredEvent"
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

-(NSMutableDictionary<NSString *,NSMutableArray<YGCategory *> *> *)categories {
    
    if(!_categories)
        [self getCategoriesForCache];
    return _categories;
}


#pragma mark - Inner methods for memory cache process

- (NSArray <YGCategory *> *)categoriesFromDb {
    
    NSString *sqlQuery = @"SELECT category_id, category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid  FROM category ORDER BY active DESC, sort ASC;";
    
    NSArray *rawCategories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
    
    for(NSArray *arr in rawCategories){
        
        NSInteger rowId = [arr[0] integerValue];
        YGCategoryType type = [arr[1] integerValue];
        NSString *name = arr[2];
        BOOL active = [arr[3] boolValue];
        NSDate *created = [YGTools dateFromString:arr[4]];
        NSDate *modified = [YGTools dateFromString:arr[5]];// [arr[5] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[5]];
        NSInteger sort = [arr[6] integerValue];
        NSString *symbol = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
        BOOL attach = [arr[8] boolValue];
        NSInteger parentId = [arr[9] isEqual:[NSNull null]] ? -1 : [arr[9] integerValue];
        NSString *comment = [arr[10] isEqual:[NSNull null]] ? nil : arr[10];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[11]];
        
        YGCategory *category = [[YGCategory alloc] initWithRowId:rowId categoryType:type name:name active:active created:created modified:modified sort:sort symbol:symbol attach:attach parentId:parentId comment:comment uuid:uuid];
        
        [result addObject:category];
    }
    return [result copy];
}


- (void)getCategoriesForCache {
    
    NSArray *categoriesRaw = [self categoriesFromDb];
    
    NSMutableDictionary <NSString *, NSMutableArray <YGCategory *> *> *categoriesResult = [[NSMutableDictionary alloc] init];
    
    NSString *typeString = nil;
    for(YGCategory *category in categoriesRaw){
        
        typeString = NSStringFromCategoryType(category.type);
        
        if([categoriesResult valueForKey:typeString]){
            [[categoriesResult valueForKey:typeString] addObject:category];
        }
        else{
            [categoriesResult setValue:[[NSMutableArray alloc] init] forKey:typeString];
            [[categoriesResult valueForKey:typeString] addObject:category];
        }
    }
    
    // sort categories in each inner array
    NSArray *types = [categoriesResult allKeys];
    for(NSString *type in types)
        [self sortCategoriesInArray:categoriesResult[type]];
    
    _categories = categoriesResult;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"CategoryManagerCurrencyCacheUpdateEvent" object:nil];
    [center postNotificationName:@"CategoryManagerExpenseCacheUpdateEvent" object:nil];
    [center postNotificationName:@"CategoryManagerIncomeCacheUpdateEvent" object:nil];
    [center postNotificationName:@"CategoryManagerCounterpartyUpdateEvent" object:nil];
}

- (void)sortCategoriesInArray:(NSMutableArray <YGCategory *>*)array {
    
    NSSortDescriptor *sortOnActiveByDesc = [[NSSortDescriptor alloc] initWithKey:@"active" ascending:NO];
    NSSortDescriptor *sortOnSortByAsc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    
    [array sortUsingDescriptors:@[sortOnActiveByDesc, sortOnSortByAsc]];
}

#pragma mark - Is it possible to delete category? 

/**
 @warning Why search in db instead of cache?
*/
- (BOOL)isJustOneCategory:(YGCategory *)category {
    
    // search all categories for the current type
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE category_type_id = %ld;", (long)category.type];
    
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if([categories count] == 1)
        return YES;
    else if([categories count] > 1)
        return NO;
    else
        @throw [NSException exceptionWithName:@"-[YGCategoryManager isJustOneCategory" reason:[NSString stringWithFormat:@"Category is not exist for the type: %ld", (long)category.type] userInfo:nil];
}


/**
 Check category for linked objects (operations, categories, etc.) existense.
 @warning Why search in db instead of cache?
 
 @category Category checked for existense of objects
 
 @return YES if linked object exists and NO if linked objects does not exists
 */
- (BOOL)hasLinkedObjectsForCategory:(YGCategory *)category {
    
    if(category.type == YGCategoryTypeCurrency) {
        
        // in entities
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id FROM entity WHERE currency_id = %ld LIMIT 1;", (long)category.rowId];
        
        NSArray *entities = [_sqlite selectWithSqlQuery:sqlQuery];
        if([entities count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeIncome){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND source_id = %ld LIMIT 1;", (long)YGOperationTypeIncome, (long)category.rowId];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
        if([categories count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeExpense){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND target_id = %ld LIMIT 1;", (long)YGOperationTypeExpense, (long)category.rowId];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
        if([categories count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeCounterparty){
        
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id FROM entity WHERE counterparty_id = %ld LIMIT 1;", (long)category.rowId];
        
        NSArray *entities = [_sqlite selectWithSqlQuery:sqlQuery];
        if([entities count] > 0)
            return YES;
    }
    else{
        @throw [NSException exceptionWithName:@"-[YGCategoryManager hasLinkedObjectsForCategory]" reason:@"Can not check for this type of category" userInfo:nil];
    }
    return NO;
}

- (BOOL)hasChildObjectForCategory:(YGCategory *)category {
    
    // search child for category
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE parent_id=%ld LIMIT 1;", (long)category.rowId];

    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

- (BOOL)hasChildObjectActiveForCategory:(YGCategory *)category {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE parent_id=%ld AND active=1 LIMIT 1;", (long)category.rowId];
    
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

/**
 @warning Why search in db instead of cache?
 */
- (BOOL)hasActiveCategoryForTypeExceptCategory:(YGCategory *)category {
    
    // search currency in operations
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE category_type_id=%ld AND active=1 AND category_id<>%ld LIMIT 1;", (long)category.type, (long)category.rowId];
    
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

- (BOOL)hasLinkedActiveEntityForCurrency:(YGCategory *)currency {
    
    // search currency in operations
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id FROM entity WHERE active=1 AND currency_id = %ld LIMIT 1;", (long)currency.rowId];
    
    NSArray *entities = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if(entities && [entities count] > 0)
        return YES;
    else
        return NO;
}

#pragma mark - Actions on category

- (NSInteger)idAddCategory:(YGCategory *)category {
    
    NSInteger rowId = -1;
    
    @try {
        
        NSArray *arrItem = [NSArray arrayWithObjects:
                            [NSNumber numberWithInteger:category.type], //category_type_id,
                            category.name, //name,
                            [NSNumber numberWithBool:category.active], //active,
                            [YGTools stringFromDate:category.created], //active_from,
                            [YGTools stringFromDate:category.modified], //active_to,
                            [NSNumber numberWithInteger:category.sort], //sort,
                            category.symbol ? category.symbol : [NSNull null], //symbol,
                            [NSNumber numberWithBool:category.attach], //attach,
                            category.parentId != -1 ? [NSNumber numberWithInteger:category.parentId] : [NSNull null], //parent_id,
                            category.comment ? category.comment : [NSNull null], //comment,
                            [category.uuid UUIDString],
                            nil];
        
        NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        rowId = [_sqlite addRecord:arrItem insertSQL:insertSQL];

    }
    @catch (NSException *exception) {
        NSLog(@"Fail in -[YGCategoryManager idAddCategory]. Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
}

- (void)addCategory:(YGCategory *)category {
    
    // add entity to db
    NSInteger rowId = [self idAddCategory:category];
    YGCategory *newCategory = [category copy];
    newCategory.rowId = rowId;
    
    // if set new default unset another ones
    if(newCategory.attach)
        [self setOnlyOneDefaultCategory:newCategory];

    // add entity to memory cache, init if needs
    if(![self.categories valueForKey:NSStringFromCategoryType(newCategory.type)])
        [self.categories setValue:[[NSMutableArray alloc] init] forKey:NSStringFromCategoryType(newCategory.type)];
    [[self.categories valueForKey:NSStringFromCategoryType(newCategory.type)] addObject:newCategory];
    [self sortCategoriesInArray:[self.categories valueForKey:NSStringFromCategoryType(newCategory.type)]];
    
    [self generateChangeCacheEventForType:category.type];
}

- (YGCategory *)categoryById:(NSInteger)categoryId type:(YGCategoryType)type {
    
    NSArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(type)];
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", categoryId];
    
    return [[categoriesByType filteredArrayUsingPredicate:idPredicate] firstObject];
}

/**
 Update category in db and memory cache. Write object as is, without any modifications.
 
 @warning It seems entity updated in EditController edit by reference, so... is it true?
 */
- (void)updateCategory:(YGCategory *)category{
    
    // get memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(category.type)];
    
    // get replaced item
    YGCategory *replacedCategory = [self categoryById:category.rowId type:category.type];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET name=%@, active=%@, created=%@, modified=%@, sort=%@, symbol=%@, attach=%@, parent_id=%@, comment=%@ WHERE category_id=%@ AND uuid=%@;",
                           [YGTools sqlStringForStringOrNull:category.name],
                           [YGTools sqlStringForBool:category.active],
                           [YGTools sqlStringForDateLocalOrNull:category.created],
                           [YGTools sqlStringForDateLocalOrNull:category.modified],
                           [YGTools sqlStringForIntOrNull:category.sort],
                           [YGTools sqlStringForStringOrNull:category.symbol],
                           [YGTools sqlStringForBool:category.attach],
                           [YGTools sqlStringForIntOrNull:category.parentId],
                           [YGTools sqlStringForStringOrNull:category.comment],
                           [YGTools sqlStringForInt:category.rowId],
                           [YGTools sqlStringForStringNotNull:[category.uuid UUIDString]]];
    
    [_sqlite execSQL:updateSQL];
    
    // if set new default unset another one
    if(!replacedCategory.attach && category.attach)
        [self setOnlyOneDefaultCategory:category];
    
    // update memory cache
    NSUInteger index = [categoriesByType indexOfObject:replacedCategory];
    categoriesByType[index] = [category copy];
    
    // sort memory cache
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];
    
    // generate special event for category with operations
    if([self hasLinkedObjectsForCategory:category]){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"CategoryManagerCategoryWithObjectsUpdateEvent" object:nil];
    }
}

- (void)deactivateCategory:(YGCategory *)category{
    
    NSDate *now = [NSDate date];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=0, modified=%@ WHERE category_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(category.type)];
    YGCategory *updateCategory = [categoriesByType objectAtIndex:[categoriesByType indexOfObject:category]];
    updateCategory.active = NO;
    updateCategory.modified = now;
    
    // sort memory cache
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];
}

- (void)activateCategory:(YGCategory *)category {
    
    NSDate *now = [NSDate date];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=1, modified=%@ WHERE category_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(category.type)];
    YGCategory *updateCategory = [categoriesByType objectAtIndex:[categoriesByType indexOfObject:category]];
    updateCategory.active = YES;
    updateCategory.modified = now;
    
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];
}

- (void)removeCategory:(YGCategory *)category{

    // update db
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM category WHERE category_id = %ld;", (long)category.rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(category.type)];
    
    NSUInteger index = [categoriesByType indexOfObject:category];
    [categoriesByType removeObjectAtIndex:index];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];
}

#pragma mark - Lists of categories

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive exceptCategory:(YGCategory *)exceptCategory {
    
    NSArray <YGCategory *> *categoriesResult = [self.categories valueForKey:NSStringFromCategoryType(type)];
    
    if(onlyActive){
        NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
        categoriesResult = [categoriesResult filteredArrayUsingPredicate:activePredicate];
    }
    
    if(exceptCategory){
        NSPredicate *exceptPredicate = [NSPredicate predicateWithFormat:@"rowId != %ld", exceptCategory.rowId];
        categoriesResult = [categoriesResult filteredArrayUsingPredicate:exceptPredicate];
    }
    return categoriesResult;
}

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive {
    return [self categoriesByType:type onlyActive:onlyActive exceptCategory:nil];
}

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type {
    return [self categoriesByType:type onlyActive:NO exceptCategory:nil];
}

#pragma mark - Auxiliary methods

/**
 Return only one attached entity for type. Terms for category: equls type, active, attach and must be only one. Else return nil.
 */
- (YGCategory *)categoryAttachedForType:(YGCategoryType)type {

    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid FROM category WHERE category_type_id=%ld AND active=1 AND attach=1;", (long)type];

    return [self categoryBySqlQuery:sqlQuery];
}

- (YGCategory *)categoryOnTopForType:(YGCategoryType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid  FROM category WHERE category_type_id=%ld AND active=1 ORDER BY sort ASC LIMIT 1;", (long)type];
    
    return [self categoryBySqlQuery:sqlQuery];
}

/**
 Inner func for categoryById:, categoryAttachedForType: and categoryOnTopForType:.
 */
- (YGCategory *)categoryBySqlQuery:(NSString *)sqlQuery {

    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
    
    NSArray *rawCategories = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if(rawCategories){
        for(NSArray *arr in rawCategories){
            
            NSInteger rowId = [arr[0] integerValue];
            YGCategoryType type = [arr[1] integerValue];
            NSString *name = arr[2];
            BOOL active = [arr[3] boolValue];
            NSDate *created = [YGTools dateFromString:arr[4]];
            NSDate *modified = [YGTools dateFromString:arr[5]]; //[arr[5] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[5]];
            NSInteger sort = [arr[6] integerValue];
            NSString *symbol = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
            BOOL attach = [arr[8] boolValue];
            NSInteger parentId = [arr[9] isEqual:[NSNull null]] ? -1 : [arr[9] integerValue];
            NSString *comment = [arr[10] isEqual:[NSNull null]] ? nil : arr[10];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[11]];
            
            YGCategory *category = [[YGCategory alloc] initWithRowId:rowId categoryType:type name:name active:active created:created modified:modified sort:sort symbol:symbol attach:attach parentId:parentId comment:comment uuid:uuid];
            
            [result addObject:category];
        }
        
        if([result count] == 0)
            return nil;
        else if([result count] > 1)
            @throw [NSException exceptionWithName:@"-[YGCategoryManager categoryBySqlQuery:]" reason:[NSString stringWithFormat:@"Undefined choice for category. Sql query: %@", sqlQuery]  userInfo:nil];
        else
            return [result objectAtIndex:0];
    }
    else
        return nil;
}

- (void)setOnlyOneDefaultCategory:(YGCategory *)category{
    
    // update db
    NSDate *now = [NSDate date];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET attach=0, modified=%@ "
                           "WHERE category_type_id = %ld AND category_id != %ld AND attach<>0;",
                           [YGTools sqlStringForDateLocalOrNull:now],
                           (long)category.type,
                           (long)category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSPredicate *unAttachedPredicate = [NSPredicate predicateWithFormat:@"type = %ld && rowId != %ld && attach != NO", category.type, category.rowId];
    
    NSArray <YGCategory *> *categoriesByType = [self categoriesByType:category.type];
    
    NSArray <YGCategory *> *updateCategories = [categoriesByType filteredArrayUsingPredicate:unAttachedPredicate];

    if([updateCategories count] > 0){
        for(YGCategory *c in updateCategories){
            c.attach = NO;
            c.modified = now;
        }
    }
}

- (void)generateChangeCacheEventForType:(YGCategoryType)type {
        
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    switch (type) {
        case YGCategoryTypeCurrency:
            [center postNotificationName:@"CategoryManagerCurrencyCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeExpense:
            [center postNotificationName:@"CategoryManagerExpenseCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeIncome:
            [center postNotificationName:@"CategoryManagerIncomeCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeCounterparty:
            [center postNotificationName:@"CategoryManagerCounterpartyCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeTag:
            [center postNotificationName:@"CategoryManagerTagCacheUpdateEvent" object:nil];
            break;
        default:
            break;
    }
}

- (BOOL)isExistActiveCategoryOfType:(YGCategoryType)type{
    
    NSArray *categoriesOfType = [self categoriesByType:type];
    
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
    
    NSArray *activeCategories = [categoriesOfType filteredArrayUsingPredicate:activePredicate];
    
    if([activeCategories count] > 0)
        return YES;
    else
        return NO;
}

- (NSInteger)countOfActiveCategoriesForType:(YGCategoryType)type {
    
    NSArray *categoriesOfType = [self categoriesByType:type];
    
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
    
    return [[categoriesOfType filteredArrayUsingPredicate:activePredicate] count];
}

- (YGCategory *)defaultCategoryOfType:(YGCategoryType)type {
    YGCategory *category = [self categoryAttachedForType:type];
    if(!category && [self countOfActiveCategoriesForType:type] == 1)
        category = [self categoryOnTopForType:type];
    return category;
}

@end
