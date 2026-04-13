//
//  YYGBackuper.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGBackuper.h"
#import "YGSQLite.h"
#import "YGDBManager.h"
#import "YYGLedgerDefine.h"
#import "YGFile.h"
#import "YGTools.h"
#import "YGConfig.h"

@implementation YYGBackuper

- (instancetype)init {
    self = [super init];
    if(self) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:kDateTimeFormatForBackupName];
        _generalFileName = [formatter stringFromDate:date];
        _generalFilePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), _generalFileName];
    }
    return self;
}

- (void)backupWithSuccessHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
    
    @try {
        
        // copy db and get name of new backup
        [self snapshotWorkDbTo:_generalFilePath];
        [self makeDescriptionFileTo:_generalFilePath];
        [self copyConfigFileTo:_generalFilePath];
        
        if ([self isTempBackupBundleValid:_generalFilePath])
            successHandler();
        else {
            errorHandler(NSLocalizedString(@"BACKUPER_BUNDLE_IS_NOT_VALID", @"Backup bundle is not valid."));
        }
    }
    @catch(NSException *ex) {
        errorHandler([ex description]);
    }
}

- (void)snapshotWorkDbTo:(NSString *)generalFilePath {

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *workFilePath = [YGSQLite databaseFullName];
    NSString *tempFilePath = [NSString stringWithFormat:@"%@.ledger.db.sqlite", generalFilePath];
    
    if(![fm copyItemAtPath:workFilePath toPath:tempFilePath error:&error]){
        NSString *message;
        if(error)
            message = [NSString stringWithFormat:@"Fail to copy work db to temp destination. Error: %@", [error description]];
        else
            message = @"Fail to copy work db to temp destination.";
        NSLog(@"%@", message);
        @throw [NSException exceptionWithName:@"YYGBackuper.snapshotWorkDbTo:" reason:message userInfo:nil];
    }
}

- (void)makeDescriptionFileTo:(NSString *)generalFileName {
    
    // save info about new backup in application config file
    // 1. get size
    NSString *databaseFileName = [NSString stringWithFormat:@"%@.%@", generalFileName, kDatabaseName];
    YGFile *backupFile = [[YGFile alloc] initWithPathFull:databaseFileName];
    NSString *backupDBSizeString = [YGTools humanViewStringForByteSize:backupFile.size];
    
    // 2. get backup date string
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    NSString *backupDateString = [formatter stringFromDate:date];
    
    // 3. get last operation date string
    YGDBManager *dm = [YGDBManager sharedInstance];
    NSString *lastOperationString = [dm lastOperation];
    
    if(!lastOperationString)
        lastOperationString = @"";
    
    // 4. description file path and dic
    NSString *descriptionFilePath = [NSString stringWithFormat:@"%@.ledger.db.sqlite.xml", generalFileName];
    
    NSDictionary *dic = @{@"BackupFileName":[descriptionFilePath lastPathComponent], @"LastOperation":lastOperationString, @"BackupDate":backupDateString, @"BackupDBSize":backupDBSizeString};
    
    if (![dic writeToFile:descriptionFilePath atomically:YES]){
        @throw [NSException exceptionWithName:@"YYGBackuper.saveInfoForBackup fails." reason:@". Fail to write to description file." userInfo:nil];
    }
}

- (void)copyConfigFileTo:(NSString *)generalFilePath {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *workFilePath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], kAppConfigName];
    NSString *tempFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName];
    
    if(![fm copyItemAtPath:workFilePath toPath:tempFilePath error:&error]){
        NSString *message;
        if(error)
            message = [NSString stringWithFormat:@"Fail to copy config file to temp destination. Error: %@", [error description]];
        else
            message = @"Fail to copy config file to temp destination.";
        NSLog(@"%@", message);
        @throw [NSException exceptionWithName:@"YYGBackuper.copyConfigFileTo: fails." reason:message userInfo:nil];
    }
}

- (BOOL)isTempBackupBundleValid:(NSString *)generalFileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check sqlite data file exists
    NSString *checkedFileName = [NSString stringWithFormat:@"%@.ledger.db.sqlite", generalFileName];
    if (![fileManager fileExistsAtPath:checkedFileName]) {
        NSLog(@"YYGBackuper. Error: sqlite data file NOT exists.");
        return NO;
    }
    
    // Check description file exists
    checkedFileName = [NSString stringWithFormat:@"%@.ledger.db.sqlite.xml", generalFileName];
    if (![fileManager fileExistsAtPath:checkedFileName]) {
        NSLog(@"YYGBackuper. Error: description file NOT exists.");
        return NO;
    }
    
    // Check app config file exists
    checkedFileName = [NSString stringWithFormat:@"%@.ledger.config.xml", generalFileName];
    if (![fileManager fileExistsAtPath:checkedFileName]) {
        NSLog(@"YYGBackuper. Error: config file NOT exists.");
        return NO;
    }
    
    return YES;
}

@end
