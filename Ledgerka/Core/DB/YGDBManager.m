//
//  YGDBManager.m
//  Ledger
//
//  Created by Ян on 06/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGDBManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import "YYGDBLog.h"
#import "YYGDBConfig.h"

@implementation YGDBManager

+ (YGDBManager *)sharedInstance{
    static YGDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGDBManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        ;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"Object YGDBManager dealloc");
#endif
}

- (BOOL)isDatabaseFileExists {
    
    NSString *pathDb = [YGSQLite databaseFullName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm fileExistsAtPath:pathDb])
        return YES;
    else
        return NO;
}

- (void)createDatabase {
    
    // Init of database
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    [sqlite createTables];
    
    [sqlite fillTables];
    
    // Set schema version of new database
    [YYGDBConfig setValue:@2 forKey:kDatabaseSchemeVersionKey];
}

- (void)deleteDatabaseFile {
    
    NSString *pathDb = [YGSQLite databaseFullName];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if(![fm removeItemAtPath:pathDb error:&error]) {
        NSLog(@"YGDBMananger deleteDatabaseFile fails. Error: %@", [error description]);
    } else {
        NSLog(@"Database file successfully deleted.");
    }
}

- (NSString *)lastOperation {
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSString *sqlQuery = @"SELECT modified FROM operation ORDER BY modified_unix DESC LIMIT 1;";
        
    NSArray *rawList = [sqlite selectWithSqlQuery:sqlQuery];
    
    NSArray *operation = [rawList firstObject];
    
    NSString *date = [operation firstObject];
    
    return [date copy];
}

/**
 Return full name of current work database. Wraper on YGSQLite method.
 
 @return Current work database full name.
 */
- (NSString *)databaseFullName {
    return [YGSQLite databaseFullName];
}

@end
