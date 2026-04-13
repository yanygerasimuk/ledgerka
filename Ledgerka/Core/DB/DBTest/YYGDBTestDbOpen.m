//
//  YYGDBTestDbOpen.m
//  Ledger
//
//  Created by Ян on 28.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDBTestDbOpen.h"
#import <sqlite3.h>

@implementation YYGDBTestDbOpen

- (instancetype)init {
    self = [super init];
    if (self){
        _rule = NSLocalizedString(@"DB_TEST_RULE_DB_MUST_OPEN_BY_SQLITE_LIBRARY", @"Opening a database by Sqlite library.");
        _isContinue = NO;
    }
    return self;
}

// TODO: Может ещё диагностику от sqlite добавить? Текущая нефига не работает!
- (BOOL)run {
    
    BOOL testResult = NO;
    
    sqlite3 *db;
    
    NSString *path = [_owner dbFileFullName];
    
    int result = sqlite3_open([path UTF8String], &db);
    
    if(result != SQLITE_OK){
        testResult = NO;
        _message = NSLocalizedString(@"DB_TEST_DB_DOES_NOT_OPEN", @"Database does not open.");
        NSLog(@"SQL error %s", sqlite3_errmsg(db));
    } else {
        testResult = YES;
        _message = NSLocalizedString(@"DB_TEST_DB_OPENS", @"Database opens successfully.");
    }
    
    sqlite3_close(db);
    
    return testResult;
}

@end
