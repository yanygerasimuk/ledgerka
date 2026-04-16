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

    dispatch_sync(queue, ^{
        NSString *path = [YYGSQLite databaseFullName];
        int result = sqlite3_open([path UTF8String], &db);
        if(result != SQLITE_OK){
            NSLog(@"[YYGSQLite database]. sqlite3_open() fails. Result: %@. Can not open sqlite db.", @(result));
            sqlite3_close(db);
        }
    });

    return db;
}

@end
