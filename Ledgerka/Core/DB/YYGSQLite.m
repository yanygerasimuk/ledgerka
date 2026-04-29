//
//  YYGSQLite.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 14.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGLedgerkaDefine.h"
#import "YYGDBLog.h"
#import "YYGDataCommon.h"
#import "YYGDataRelease.h"
#import "YYGResult.h"

#import <sqlite3.h>
#import "YYGSQLite.h"
#import "YGTools.h"


@interface YYGSQLite() {
    dispatch_queue_t queue;
}
@end


@implementation YYGSQLite

- (instancetype) init{
    self = [super init];
    if(self){
        queue = dispatch_queue_create(kSQLiteQueue, NULL);

        // TODO: Think about checking db
//        [self checkDatabase];
    }
    return self;
}

- (void)execAsyncSql:(NSString *)sqlQuery
      successHandler:(void (^) (void))successHandler
      failureHandler:(void (^) (void))failureHandler
{
    __block NSInteger result = NSNotFound;
    __weak YYGSQLite *weakSelf = self;

    dispatch_sync(queue, ^{
        YYGSQLite *strongSelf = weakSelf;
        if(!strongSelf)
            failureHandler();
        sqlite3 *db = [strongSelf database];
        if(!db)
            failureHandler();

        char *error;
        result = sqlite3_exec(db, [sqlQuery UTF8String], NULL, NULL, &error);
        if (result != SQLITE_OK)
        {
            NSLog(@"YYGSQLite execAsyncSql fails. SQL: %@\nReturn: %ld\nerror: %@", sqlQuery, (long)result, [NSString stringWithUTF8String:error]);
            sqlite3_free(error);
        }
        sqlite3_close(db);
        successHandler();
    });
}

- (void)insertAsyncSql:(NSString *)sql
                fields:(NSArray *)fields
        successHandler:(void (^) (NSInteger))successHandler
        failureHandler:(void (^) (void))failureHandler
{
    __block NSInteger recordId = -1;
    __weak YYGSQLite *weakSelf = self;

    dispatch_sync(queue, ^{
        YYGSQLite *strongSelf = weakSelf;
        if(!strongSelf)
            failureHandler();
        sqlite3 *db = [strongSelf database];
        if(!db)
            failureHandler();

        sqlite3_stmt *stmt;
        NSInteger prepareResult = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
        if(prepareResult != SQLITE_OK)
        {
            NSLog(@"[YYGSQLite asyncInsertObjectWithFields:sql:s:f:]. sqlite_prepare_v2() fail. Return: %ld", (long)prepareResult);
            sqlite3_finalize(stmt);
            sqlite3_close(db);
            failureHandler();
        }

        for(int i = 0; i < [fields count]; i++){

            id field = fields[i];

            if([field isKindOfClass:[NSNumber class]]){

                if(strcmp([field objCType], @encode(double)) == 0){
                    if(sqlite3_bind_double(stmt, i+1, [field doubleValue]) != SQLITE_OK){
                        NSLog(@"Can not bind double");
                    }
                }
                else if((strcmp([field objCType], @encode(long)) == 0)
                        || (strcmp([field objCType], @encode(int)) == 0)){
                    if(sqlite3_bind_int(stmt, i+1, [field intValue]) != SQLITE_OK){
                        NSLog(@"Can not bind int");
                    }
                }
                else if(strcmp([field objCType], @encode(BOOL)) == 0){ // BOOL as int, Do not work, see below
                    if(sqlite3_bind_int(stmt, i+1, [field boolValue]) != SQLITE_OK){
                        NSLog(@"Can not bind bool");
                    }
                }
                else if(strcmp([field objCType], "c") == 0){ // BOOL as char, crutch!
                    int intBool = (int)[field boolValue];
                    if(sqlite3_bind_int(stmt, i+1, intBool) != SQLITE_OK){
                        NSLog(@"Can not bind bool");
                    }
                }
                else{
                    @throw [NSException exceptionWithName:@"-[YGSQLite fillTable:items:updateSQL]" reason:[NSString stringWithFormat:@"Can not bind NSNumber object. field type: %s, column: %d, class: %@", [field objCType], i+1, NSStringFromClass([field class])] userInfo:nil];
                }
            }
            else if([field isKindOfClass:[NSString class]]){
                if(sqlite3_bind_text(stmt, i+1, [field UTF8String], -1, NULL) != SQLITE_OK){
                    NSLog(@"Can not bind text");
                }
            }
            else if([field isKindOfClass:[NSNull class]]){
                if(sqlite3_bind_null(stmt, i+1) != SQLITE_OK){
                    NSLog(@"Can not bind null");
                }
            }
            else{
                NSLog(@"undefined item class: %@, description: %@", [field class], [field description]);
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                failureHandler();
            }
        }

        NSInteger stepResult = sqlite3_step(stmt);
        if(stepResult != SQLITE_DONE)
        {
            NSLog(@"sqlite_step() fail: Returned code: %@", [NSString stringWithUTF8String:sqlite3_errmsg(db)]);
            sqlite3_finalize(stmt);
            sqlite3_close(db);
            failureHandler();
        }

        // 9223372036854775807 not enough?
        recordId = (NSInteger)sqlite3_last_insert_rowid(db);
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        successHandler(recordId);
    });
}

- (NSArray *)selectWithSql:(NSString *)sql
{
#ifdef DEBUG_PERFORMANCE
    NSLog(@"-[YYGSQLite selectWithSql: %@]", sql);
#endif

    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __weak YYGSQLite *weakSelf = self;
    dispatch_sync(queue, ^{
        YYGSQLite *strongSelf = weakSelf;
        if(strongSelf) {
            sqlite3 *db = [strongSelf database];
            sqlite3_stmt *statement;

            int resultSqlitePrepare = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil);

            if (resultSqlitePrepare == SQLITE_OK) {

                while (sqlite3_step(statement) == SQLITE_ROW) {
                    NSMutableArray *row = [[NSMutableArray alloc] init];
                    for(int i = 0; i < sqlite3_column_count(statement); i++){
                        int columnType = sqlite3_column_type(statement, i);
                        if(columnType == 1){ //int
                            int intVal = sqlite3_column_int(statement, i);
                            [row addObject:[NSNumber numberWithInt:intVal]];
                        }
                        else if(columnType == 2){ // double
                            double doubleVal = sqlite3_column_double(statement, i);
                            [row addObject:[NSNumber numberWithDouble:doubleVal]];
                        }
                        else if(columnType == 3){ //text
                            const char *charValue = (char *)sqlite3_column_text(statement, i);
                            if(charValue != NULL)
                                [row addObject:[[NSString alloc] initWithUTF8String:charValue]];
                            else
                                [row addObject:[NSNull null]];
                        }
                        else if(columnType == 5){
                            [row addObject:[NSNull null]];
                        }
                        else {
                            @throw [NSException exceptionWithName:@"-[YYGSQLite selectWithSql]" reason:@"Can not get value of selected type" userInfo:nil];
                        }
                    }
                    [result addObject:row];
                }
            } else {
                NSLog(@"-[YYGSQLite selectWithSql] .. sqlite3_prepare_v2() != SQLITE_OK. Result: %d", resultSqlitePrepare);
                NSLog(@"Unable to prepare statement: %s db err '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(db), sqlite3_errcode(db));
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
#ifdef DEBUG_PERFORMANCE
            NSLog(@"<< selectWithSql finished");
#endif
        }
    });
    return [result count] > 0 ? [result copy] : nil;
}

- (void)selectAsyncSql:(NSString *)sql
        successHandler:(void (^) (NSArray *))successHandler
        failureHandler:(void (^) (void))failureHandler
{
#ifdef DEBUG_PERFORMANCE
    NSLog(@"YGSQLite.selectWithSqlQuery:");
#endif
    NSLog(@"YGSQLite.selectWithSqlQuery:");
    NSLog(@"sql: %@", sql);
    NSLog(@"\t isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");

    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __weak YYGSQLite *weakSelf = self;
    dispatch_async(queue, ^{

        NSLog(@"\t\tYGSQLite.selectWithSqlQuery: { inside dispatch_sync }");
        NSLog(@"\t\t isMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");

        YYGSQLite *strongSelf = weakSelf;
        if(strongSelf) {
            sqlite3 *db = [strongSelf database];
            sqlite3_stmt *statement;

            int resultSqlitePrepare = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil);

            if (resultSqlitePrepare == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    NSMutableArray *row = [[NSMutableArray alloc] init];
                    for(int i = 0; i < sqlite3_column_count(statement); i++){
                        int columnType = sqlite3_column_type(statement, i);
                        if(columnType == 1){ //int
                            int intVal = sqlite3_column_int(statement, i);
                            [row addObject:[NSNumber numberWithInt:intVal]];
                        }
                        else if(columnType == 2){ // double
                            double doubleVal = sqlite3_column_double(statement, i);
                            [row addObject:[NSNumber numberWithDouble:doubleVal]];
                        }
                        else if(columnType == 3){ //text
                            const char *charValue = (char *)sqlite3_column_text(statement, i);
                            if(charValue != NULL)
                                [row addObject:[[NSString alloc] initWithUTF8String:charValue]];
                            else
                                [row addObject:[NSNull null]];
                        }
                        else if(columnType == 5){
                            [row addObject:[NSNull null]];
                        }
                        else {
                            // @throw [NSException exceptionWithName:@"-[YGSQLite selectWithSqlQuery]" reason:@"Can not get value of selected type" userInfo:nil];
                            failureHandler();
                        }
                    }
                    [result addObject:row];
                }
                sqlite3_finalize(statement);
                sqlite3_close(db);
                successHandler(result);
            } else {
                NSLog(@"-[YGSQLite selectWithSqlQuery] .. sqlite3_prepare_v2() != SQLITE_OK. Result: %d", resultSqlitePrepare);
                NSLog(@"Unable to prepare statement: %s db err '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(db), sqlite3_errcode(db));
                sqlite3_finalize(statement);
                sqlite3_close(db);
                failureHandler();
            }
#ifdef DEBUG_PERFORMANCE
            NSLog(@"<< selectWithSqlQuery finished");
#endif
        }
        else
        {
            // а нужно ли?
            failureHandler();
        }
    });
}


#pragma mark - Statics

+ (YYGSQLite *)shared
{
    static YYGSQLite *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YYGSQLite alloc] init];
    });
    return instance;
}

+ (NSString *)databaseFullName {
    static NSString *databaseFullName = nil;

    if(databaseFullName)
        return [databaseFullName copy];
    else{
        NSString *documentsDirectory = [YGTools documentsDirectoryPath];
        databaseFullName = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
        return [databaseFullName copy];
    }
}

#pragma mark - Private

- (BOOL)isDatabaseFileExist {
    NSString *path = [YYGSQLite databaseFullName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]) {
        return YES;
    } else {
        NSLog(@"Database file is not exist at path: %@", path);
        return NO;
    }
}

- (sqlite3 *)database
{
    __block sqlite3 *db;

    NSString *path = [YYGSQLite databaseFullName];
    int result = sqlite3_open([path UTF8String], &db);
    if(result != SQLITE_OK){
        NSLog(@"[YYGSQLite database]. sqlite3_open() fails. Result: %@. Can not open sqlite db.", @(result));
        sqlite3_close(db);
    }

//    dispatch_sync(queue, ^{
//        NSString *path = [YYGSQLite databaseFullName];
//        int result = sqlite3_open([path UTF8String], &db);
//        if(result != SQLITE_OK){
//            NSLog(@"[YYGSQLite database]. sqlite3_open() fails. Result: %@. Can not open sqlite db.", @(result));
//            sqlite3_close(db);
//        }
//    });

    return db;
}

@end
