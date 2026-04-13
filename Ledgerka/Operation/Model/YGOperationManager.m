//
//  YGOperationManager.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGEntityManager.h"
#import "YGConfig.h"

@interface YGOperationManager() {
    YGSQLite *_sqlite;
}
- (YGOperation *)operationBySqlQuery:(NSString *)sqlQuery;
- (NSArray <YGOperation *> *)operationsBySqlQuery:(NSString *)sqlQuery;
@end

@implementation YGOperationManager

@synthesize operations = _operations;

#pragma mark - sharedInstanse & init

+ (instancetype)sharedInstance {
    static YGOperationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGOperationManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _sqlite = [YGSQLite sharedInstance];
        _operations = [[NSMutableArray alloc] init];
        [self getOperationsForCache];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(getOperationsForCache)
                       name:@"DatabaseRestoredEvent"
                     object:nil];
    }
    return self;
}


- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

/**
 @warning Массиву нельзя присваивать nil, так как в этом случае нельзя будет добавлять объекты
 */
- (void)setOperations:(NSMutableArray<YGOperation *> *)operations {
    
    if(operations && ![_operations isEqual:operations])
        _operations = [operations mutableCopy];
    else if(!operations && [_operations count] > 0)
        [_operations removeAllObjects];
    
    // Нужно извещать и в том случае, если операций нет, такое возможно при восстановлении из пусто бд
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
}


#pragma mark - Inner methods for memory cache process

- (void) getOperationsForCache {
    NSString *sqlQuery = @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation ORDER BY day_unix DESC, modified_unix DESC;";
    self.operations = [[self operationsBySqlQuery:sqlQuery] mutableCopy];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerDataSourceUpdateEvent"
                          object:nil];
}


/**
 Sort operations in cache array. First sort: day, second: modified.
 */
- (void)sortOperationsInArray:(NSMutableArray <YGOperation *> *)array {
    NSSortDescriptor *sortOnDayByDesc = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    NSSortDescriptor *sortOnCreatedByDesc = [[NSSortDescriptor alloc] initWithKey:@"modified" ascending:NO];
    
    [array sortUsingDescriptors:@[sortOnDayByDesc, sortOnCreatedByDesc]];
}

#pragma mark - Actions on operation(s)

- (NSInteger)addOperation:(YGOperation *)operation {
    
    NSInteger operationId;
    
    @try {
        // 1. Add to db
        operationId = [self insertIntoDb:operation];
        
        // 2. Make additional actions for some operations
        switch (operation.type) {
            case YGOperationTypeAccountActual:
                [self additionalActionsForNewAccountActual:operation];
                break;
            case YGOperationTypeSetDebt:
                [self additionalActionsForNewSetDebt:operation];
                break;
            default:
                break;
        }
        
        // 3. Add to memory cache
        YGOperation *newOperation = [operation copy];
        newOperation.rowId = operationId;
        [self insertIntoCache:newOperation];
        
        return operationId;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in -[YGOperationManager addOperation]. Description: %@.", [exception description]);
    }
}

- (NSInteger)insertIntoDb:(YGOperation *)operation {
    NSInteger operationId = 0; // return value
    
    NSNumber *operation_type_id = [NSNumber numberWithInteger:operation.type];
    NSNumber *source_id = [NSNumber numberWithInteger:operation.sourceId];
    NSNumber *target_id = [NSNumber numberWithInteger:operation.targetId];
    NSNumber *source_sum = [NSNumber numberWithDouble:operation.sourceSum];
    NSNumber *source_currency_id = [NSNumber numberWithInteger:operation.sourceCurrencyId];
    NSNumber *target_sum = [NSNumber numberWithDouble:operation.targetSum];
    NSNumber *target_currency_id = [NSNumber numberWithInteger:operation.targetCurrencyId];
    
    NSString *day = [YGTools stringFromAbsoluteDate:operation.day];
    NSNumber *day_unix = [NSNumber numberWithDouble:[operation.day timeIntervalSince1970]];
    NSString *created = [YGTools stringFromLocalDate:operation.created];
    NSNumber *created_unix = [NSNumber numberWithDouble:[operation.created timeIntervalSince1970]];
    NSString *modified = [YGTools stringFromLocalDate:operation.modified];
    NSNumber *modified_unix = [NSNumber numberWithDouble:[operation.modified timeIntervalSince1970]];
    
    NSString *comment = operation.comment;
    NSString *uuid = [operation.uuid UUIDString];
    
    @try {
        NSArray *operationArr = [NSArray arrayWithObjects:
                                 operation_type_id,
                                 source_id,
                                 target_id,
                                 source_sum,
                                 source_currency_id,
                                 target_sum,
                                 target_currency_id,
                                 day,
                                 day_unix,
                                 created,
                                 created_unix,
                                 modified,
                                 modified_unix,
                                 comment ? comment : [NSNull null],
                                 uuid,
                                 nil];
        
        NSString *insertSQL = @"INSERT INTO operation (operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, day_unix, created, created_unix, modified, modified_unix, comment, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        operationId = [_sqlite addRecord:operationArr insertSQL:insertSQL];
        
        return operationId;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in -[YGOperationManager insertIntoDb]. %@.", [exception description]);
    }
}

- (void)additionalActionsForNewAccountActual:(YGOperation *)accountActual {
    // update account sum colomn
    YGEntityManager *em = [YGEntityManager sharedInstance];
    
    YGEntity *account = [em entityById:accountActual.targetId type:YGEntityTypeAccount];
    
    account.sum = accountActual.targetSum;
    account.modified = [NSDate date];
    
    // check
    if(account.currencyId != accountActual.sourceCurrencyId || account.currencyId != accountActual.targetCurrencyId)
        @throw [NSException exceptionWithName:@"YGOperationManager additionalActionsForNewAccountActual:" reason:@"AccountActual operation currency is not equal account currency" userInfo:nil];
    
    [em updateEntity:account];
}

- (void)additionalActionsForNewSetDebt:(YGOperation *)setDebt {
    
    YGEntityManager *em = [YGEntityManager sharedInstance];
    
    YGEntity *debt = [em entityById:setDebt.targetId type:YGEntityTypeDebt];
    
    debt.sum = setDebt.targetSum;
    debt.modified = [NSDate date];
    
    // check
    if(debt.currencyId != setDebt.sourceCurrencyId || debt.currencyId != setDebt.targetCurrencyId)
        @throw [NSException exceptionWithName:@"YGOperationManager additionalActionsForNewSetDebt:" reason:@"SetDebt operation currency is not equal account currency" userInfo:nil];
    
    [em updateEntity:debt];
}

- (void)insertIntoCache:(YGOperation *)newOperation {

    NSInteger earlyIndex = [self.operations indexOfObjectPassingTest:^BOOL(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([newOperation.day timeIntervalSince1970] > [obj.day timeIntervalSince1970])
            return YES;
        else
            return NO;
    }];
    NSInteger equalIndex = [self.operations indexOfObjectPassingTest:^BOOL(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([newOperation.day timeIntervalSince1970] == [obj.day timeIntervalSince1970])
            return YES;
        else
            return NO;
    }];
    NSInteger laterIndex = [self.operations indexOfObjectPassingTest:^BOOL(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([newOperation.day timeIntervalSince1970] < [obj.day timeIntervalSince1970])
            return YES;
        else
            return NO;
    }];
    
#if DEBUG_FUNC
    NSLog(@"earlyIndex: %ld, equalIndex: %ld, laterIndex: %ld", (long)earlyIndex, (long)equalIndex, (long)laterIndex);
#endif
    
    if (earlyIndex == NSNotFound && equalIndex == NSNotFound && laterIndex == NSNotFound)
        [self.operations addObject:newOperation];
    else if (earlyIndex == NSNotFound && equalIndex != NSNotFound && laterIndex == NSNotFound)
        [self.operations addObject:newOperation];
    else if (earlyIndex == NSNotFound && equalIndex == NSNotFound && laterIndex != NSNotFound)
        [self.operations insertObject:newOperation atIndex:0];
    else if (earlyIndex != NSNotFound && equalIndex != NSNotFound && laterIndex != NSNotFound)
        [self.operations insertObject:newOperation atIndex:equalIndex];
    else if (earlyIndex != NSNotFound && equalIndex == NSNotFound && laterIndex != NSNotFound)
        [self.operations insertObject:newOperation atIndex:earlyIndex];
    else if (earlyIndex != NSNotFound && equalIndex != NSNotFound && laterIndex == NSNotFound)
        [self.operations insertObject:newOperation atIndex:equalIndex]; // or atIndex:0
    else if (earlyIndex == NSNotFound && equalIndex != NSNotFound && laterIndex != NSNotFound)
        [self.operations insertObject:newOperation atIndex:equalIndex];
    else if (earlyIndex != NSNotFound && equalIndex == NSNotFound && laterIndex == NSNotFound)
        [self.operations insertObject:newOperation atIndex:earlyIndex]; // or atIndex:0
    
    // 3. Add operation to sectionWithOperations dataSource
    if (_sectionDelegate)
        [_sectionDelegate addOperation:newOperation];
    
    // 4. Post notification about cache update
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
    
}

- (YGOperation *)operationById:(NSInteger)operationId {
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", operationId];
    
    return [[self.operations filteredArrayUsingPredicate:idPredicate] firstObject];
}

/**
 Update operations in db, memory cache and sections dataSource.
 Write object as is, without any modifications.
 */
- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation {
//#define FUNC_DEBUG
#ifdef FUNC_DEBUG
    NSLog(@"YGOperationMananger.updateOperation:withNew:");
    NSLog(@"old operation:\n%@", [oldOperation description]);
    NSLog(@"new operation:\n%@", [newOperation description]);
#endif
    
    @try {
        // 1. Update db
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE operation SET operation_type_id=%@, source_id=%@, target_id=%@, source_sum=%@, source_currency_id=%@, target_sum=%@, target_currency_id=%@, day=%@, day_unix=%@, created=%@, created_unix=%@, modified=%@, modified_unix=%@, comment=%@, uuid=%@ WHERE operation_id=%@;",
                               [YGTools sqlStringForInt:newOperation.type],
                               [YGTools sqlStringForInt:newOperation.sourceId],
                               [YGTools sqlStringForInt:newOperation.targetId],
                               [YGTools sqlStringForDecimal:newOperation.sourceSum],
                               [YGTools sqlStringForInt:newOperation.sourceCurrencyId],
                               [YGTools sqlStringForDecimal:newOperation.targetSum],
                               [YGTools sqlStringForInt:newOperation.targetCurrencyId],
                               [YGTools sqlStringForDateAbsoluteOrNull:newOperation.day],
                               [YGTools sqlStringForDouble:[newOperation.day timeIntervalSince1970]],
                               [YGTools sqlStringForDateLocalOrNull:newOperation.created],
                               [YGTools sqlStringForDouble:[newOperation.created timeIntervalSince1970]],
                               [YGTools sqlStringForDateLocalOrNull:newOperation.modified],
                               [YGTools sqlStringForDouble:[newOperation.modified timeIntervalSince1970]],
                               [YGTools sqlStringForStringOrNull:newOperation.comment],
                               [YGTools sqlStringForStringNotNull:[newOperation.uuid UUIDString]],
                               [YGTools sqlStringForInt:oldOperation.rowId]
                               ];
        [_sqlite execSQL:updateSQL];
        
        // 2. Update memory cache
        // Not work - it's a copy object!
        //NSUInteger index = [self.operations indexOfObject:oldOperation];
        NSUInteger index = [self.operations indexOfObjectPassingTest:^BOOL(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (oldOperation.rowId == obj.rowId)
                return YES;
            else
                return NO;
        }];
                
        self.operations[index] = [newOperation copy];
        
        // Need sort? It seems at any case YES.
        [self sortOperationsInArray:self.operations];
        
        // 3. Update sections dataSource
        if (_sectionDelegate)
            [_sectionDelegate updateOperation:oldOperation withNew:newOperation];
        
        // 4. Post notification about update
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                              object:nil];
    }
    @catch (NSException *ex) {
        NSLog(@"Exception in YGOperationManager.updateOperation:withNew:. Description: %@", [ex description]);
    }
}

- (void)removeOperation:(YGOperation *)operation {
    
    // 1. Remove from db
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM operation WHERE operation_id = %ld;", (long)operation.rowId];
    [_sqlite removeRecordWithSQL:deleteSQL];
    
    // 2. Remove from memory cache
    [self.operations removeObject:operation];
    
    // 3. Remove from section dataSource
    if (_sectionDelegate)
        [_sectionDelegate removeOperation:operation];
    
    // 4. Post notification about cache update
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
}

- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId {
    // TODO: replace for call designed func
    NSPredicate *operPredicate = [NSPredicate predicateWithFormat:@"(type IN {6,7} AND sourceId = %ld) OR (type IN {5,8} AND targetId = %ld) OR (type = 2 AND sourceId = %ld) OR (type = 1 AND targetId = %ld) OR (type = 4 AND (sourceId = %ld OR targetId = %ld))", accountId, accountId, accountId, accountId, accountId, accountId];
    return [self.operations filteredArrayUsingPredicate:operPredicate];
}

- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId sinceAccountActual:(YGOperation *)operation {
    
    NSPredicate *operPredicate = [NSPredicate predicateWithFormat:@"(day >= %@ AND modified >= %@) AND ((type IN {6,7} AND sourceId = %ld) OR (type IN {5,8} AND targetId = %ld) OR (type = 2 AND sourceId = %ld) OR (type = 1 AND targetId = %ld) OR (type = 4 AND (sourceId = %ld OR targetId = %ld)))", operation.day, operation.modified, accountId, accountId, accountId, accountId, accountId, accountId];
    
    return [self.operations filteredArrayUsingPredicate:operPredicate];
}

- (NSArray <YGOperation *> *)operationsWithDebtId:(NSInteger)debtId {
    NSPredicate *operWithDebts = [NSPredicate predicateWithFormat:@"(type IN {5,8} AND sourceId = %ld) OR (type IN {6,7,9} AND targetId = %ld)", debtId, debtId];
    return [self.operations filteredArrayUsingPredicate:operWithDebts];
}

- (NSArray <YGOperation *> *)operationsWithDebtId:(NSInteger)debtId afterSetDebt:(YGOperation *)operation {
    NSArray <YGOperation *> *operations = [self operationsWithDebtId:debtId];
    NSPredicate *operLaterThen = [NSPredicate predicateWithFormat:@"day >= %@ AND modified >= %@", operation.day, operation.modified];
    return [operations filteredArrayUsingPredicate:operLaterThen];
}

- (NSArray <YGOperation *> *)operationsWithTargetId:(NSInteger)targetId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE target_id=%ld ORDER BY created_unix DESC;", (long)targetId];

    return [self operationsBySqlQuery:sqlQuery];
}

- (NSArray <YGOperation *> *)operationsOfType:(YGOperationType)type withSourceId:(NSInteger)sourceId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld AND source_id=%ld ORDER BY created_unix DESC;", (long)type, (long)sourceId];
    
    return [self operationsBySqlQuery:sqlQuery];
}

- (NSArray <YGOperation *> *)operationsBySqlQuery:(NSString *)sqlQuery {
//#define FUNC_DEBUG
#ifdef FUNC_DEBUG
    NSLog(@"YGOperationManager.operationsBySqlQuery:");
#endif
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
#ifdef DEBUG_PERFORMANCE
    NSLog(@"Mapping sqlite result to ponso array");
#endif
    
    if(rawList) {
        NSMutableArray <YGOperation *> *result = [[NSMutableArray alloc] init];
        
        [rawList enumerateObjectsUsingBlock:^(id  _Nonnull arr, NSUInteger idx, BOOL * _Nonnull stop) {
            YGOperation *operation = [[YGOperation alloc]
                                      initWithRowId:[arr[0] integerValue]
                                      type:[arr[1] integerValue]
                                      sourceId:[arr[2] integerValue]
                                      targetId:[arr[3] integerValue]
                                      sourceSum:[arr[4] doubleValue]
                                      sourceCurrencyId:[arr[5] integerValue]
                                      targetSum:[arr[6] doubleValue]
                                      targetCurrencyId:[arr[7] integerValue]
                                      day:[arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]]
                                      created:[arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]]
                                      modified: [arr[10] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[10]]
                                      comment:[arr[11] isEqual:[NSNull null]] ? nil : arr[11]
                                      uuid:[[NSUUID alloc] initWithUUIDString:arr[12]]];
            [result addObject:operation];
        }];
        
#ifdef DEBUG_PERFORMANCE
        NSLog(@"<< operationsBySqlQuery finished");
#endif
        
        return [result copy];
    }
    else
        return nil;
}

/**
 Wrapper on operationBySqlQuery:.
 */
- (YGOperation *)lastOperationForType:(YGOperationType)type {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld ORDER BY created_unix DESC LIMIT 1;", (long)type];
    return [self operationBySqlQuery:sqlQuery];
}

- (YGOperation *)lastOperationOfType:(YGOperationType)type withTargetId:(NSInteger)targetId {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld AND target_id=%ld ORDER BY created_unix DESC LIMIT 1;", (long)type, (long)targetId];
    return [self operationBySqlQuery:sqlQuery];
}

- (YGOperation *)operationBySqlQuery:(NSString *)sqlQuery {
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if(rawList) {
        NSMutableArray <YGOperation *> *result = [[NSMutableArray alloc] init];
        
        for(NSArray *arr in rawList){
            
            NSInteger rowId = [arr[0] integerValue];
            YGOperationType type = [arr[1] integerValue];
            NSInteger sourceId = [arr[2] integerValue];
            NSInteger targetId = [arr[3] integerValue];
            double sourceSum = [arr[4] doubleValue];
            NSInteger sourceCurrencyId = [arr[5] integerValue];
            double targetSum = [arr[6] doubleValue];
            NSInteger targetCurrencyId= [arr[7] integerValue];
            NSDate *day = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
            NSDate *created = [arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]];
            NSDate *modified = [arr[10] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[10]];
            NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[12]];
            
            YGOperation *operation = [[YGOperation alloc] initWithRowId:rowId type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId day:day created:created modified:modified comment:comment uuid:uuid];
            
            [result addObject:operation];
        }
        
        if([result count] == 0)
            return nil;
        else if([result count] > 1)
            @throw [NSException exceptionWithName:@"-[YGOperationManager operationBySqlQuery]" reason:[NSString stringWithFormat:@"Undefined choice for operation. Sql query: %@", sqlQuery]  userInfo:nil];
        else
            return [result objectAtIndex:0];
    }
    else
        return nil;
}

@end
