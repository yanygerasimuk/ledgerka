//
//  YGSQLite.h
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGSQLite : NSObject

- (instancetype) init;
+ (YGSQLite *)sharedInstance;

- (BOOL)isDatabaseFileExist;
- (BOOL)isDatabaseOpenable;

- (void)createTables;
- (void)fillTables;

- (void)fillTable:(NSString *)tableName items:(NSArray *)items updateSQL:(NSString *)updateSQL;

- (NSInteger)addRecord:(NSArray *)fieldsOfItem insertSQL:(NSString *)insertSQL;
- (NSArray *)selectWithSqlQuery:(NSString *)sqlQuery;
- (void)removeRecordWithSQL:(NSString *)deleteSQL;
- (void)execSQL:(NSString *)sqlQuery;

+ (NSString *)databaseName;
+ (NSString *)databaseFullName;

- (BOOL)hasColumn:(NSString *)column inTable:(NSString *)table;

/// Sync exec some sql in one transaction
/// - Parameter sqls: List of sql strings
/// - Returns: Result
- (BOOL)execSyncInTransactionSQLs:(NSArray<NSString *> *)sqls;

/// Async exec some sql in one transaction
/// - Parameters:
///   - sqls: List of sql strings
///   - successBlock: Block executed on success
///   - failureBlock: Block executed on failure
- (void)execAsyncInTransactionSQLs:(NSArray<NSString *> *)sqls
                      successBlock:(void (^) (void))successBlock
                      failureBlock:(void (^) (void))failureBlock;

@end
