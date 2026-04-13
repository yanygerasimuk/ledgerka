//
//  YYGDatabaseInfo.m
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDatabaseInfo.h"
#import "YGDBManager.h"
#import "YGTools.h"
#import "YGFile.h"

@implementation YYGDatabaseInfo

- (instancetype)initWithLastOperation:(NSString *)lastOperation databaseSize:(NSString *)databaseSize backupDate:(NSString *)backupDate {
    self = [super init];
    if(self) {
        self.lastOperation = lastOperation;
        self.databaseSize = databaseSize;
        self.backupDate = backupDate;
    }
    return self;
}

- (instancetype)initWithWorkDb {
    YGDBManager *dbManager = [YGDBManager sharedInstance];
    NSString *lastOperation = [dbManager lastOperation];
    
    YGFile *workDbFile = [[YGFile alloc] initWithPathFull:[dbManager databaseFullName]];
    NSString *databaseSize = [YGTools humanViewStringForByteSize:workDbFile.size];
    
    return [self initWithLastOperation:lastOperation databaseSize:databaseSize backupDate:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    return [self initWithLastOperation:[dictionary objectForKey:@"LastOperation"] databaseSize:[dictionary objectForKey:@"BackupDBSize"] backupDate:[dictionary objectForKey:@"BackupDate"]];
}

- (NSString *)lastOperation {
    if(_lastOperation)
        return [YGTools humanViewShortWithTodayOfDateString:_lastOperation];
    else
        return NSLocalizedString(@"NO_OPERATIONS_LABEL", @"No operation text in Local backup form");
}

- (NSString *)backupDate {
    return [YGTools humanViewShortWithTodayOfDateString:_backupDate];
}

@end
