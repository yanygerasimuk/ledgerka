//
//  YYGStorageLocal.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorageLocal.h"
#import "YGTools.h"
#import "YGFileSystem.h"
#import "YGSQLite.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import "YGDBManager.h"
#import "YYGDBLog.h"

// TODO: insert term compilation

@interface YYGStorageLocal () {
    YYGDatabaseInfo *p_backupInfo;
}
@end

@implementation YYGStorageLocal

#pragma mark - YYGStoraging

- (BOOL)isNeedLoadView {
    return NO;
}

- (void)checkBackup {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"-YYGStorageLocal checkBackup...");
#endif
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_DOWNLOAD_BACKUP_INFO_MESSAGE", @"Download backup info...")];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *backupDir = [NSString stringWithFormat:@"%@/Backup/", [YGTools documentsDirectoryPath]];
    NSError *error;
    
    // 1. Проверяем наличие папки Backup...
    if(![YYGStorage isDirectoryExistsAt:backupDir]) {
        
#ifdef FUNC_DEBUG
        NSLog(@"New backup dir: %@", backupDir);
#endif
        
        if(![fileManager createDirectoryAtPath:backupDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Can not create backup directory.");
            if(error)
                NSLog(@"Error: %@", [error description]);
            return;
        }
        
    } else {
        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:backupDir error:&error];
        if([fileNames count] == 0){
            NSLog(@"No files");
            return;
        }
        if(!fileNames && error){
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSString *backupFileName = [YYGStorage backupFileNameFrom:[fileNames mutableCopy]];
        NSLog(@"backupFileName: %@", backupFileName);
        NSString *backupFileFullName = [NSString stringWithFormat:@"%@/Backup/%@.xml", [YGTools documentsDirectoryPath], backupFileName];
        if(backupFileFullName) {
            p_backupInfo = [YYGStorage backupInfoFrom:backupFileFullName];
            if(p_backupInfo)
                [self.owner notifyIsBackupExists:YES];
            else
                [self.owner notifyIsBackupExists:NO];
        }
    }
}

- (YYGDatabaseInfo *)backupInfo {
    return p_backupInfo;
}

#pragma mark - Backup to local directory

- (void)backup:(NSString *)generalFilePath {
    
    // Get list of all current backups, for deletion after copy db
    NSArray *oldBackupFiles = [self oldBackupFiles];
    
    // Make filenames of local files in temp destination
    NSString *databaseFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName];
    NSString *descriptionFilePath = [NSString stringWithFormat:@"%@.%@.xml", generalFilePath, kDatabaseName];
    NSString *configFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName];
    
    // Copy db
    [self copyTempFile:databaseFilePath successHandler:^{
        // Copy description
        [self copyTempFile:descriptionFilePath successHandler:^{
            // Copy config
            [self copyTempFile:configFilePath successHandler:^{
                // Remove old backups
                [self removeOldBackup:oldBackupFiles successHandler:^{
                    [YYGDBLog logEvent:[NSString stringWithFormat:@"Database, description and config files successfully backup to local storage."]];
                    [self checkBackup];
                } errorHandler:^(NSString *message) {
                    [YYGDBLog logEvent:[NSString stringWithFormat:@"Fail to backup to local storage. Description: %@", message]];
                    [self.owner notifyBackupWithErrorMessage:[NSString stringWithFormat:@"%@", message]];
                }];
            } errorHandler:^(NSString *message) {
                [YYGDBLog logEvent:[NSString stringWithFormat:@"Fail to backup to local storage. Description: %@", message]];
                [self.owner notifyBackupWithErrorMessage:[NSString stringWithFormat:@"%@", message]];
            }];
        } errorHandler:^(NSString *message) {
            [YYGDBLog logEvent:[NSString stringWithFormat:@"Fail to backup to local storage. Description: %@", message]];
            [self.owner notifyBackupWithErrorMessage:[NSString stringWithFormat:@"%@", message]];
        }];
    } errorHandler:^(NSString *message) {
        [YYGDBLog logEvent:[NSString stringWithFormat:@"Fail to backup to local storage. Description: %@", message]];
        [self.owner notifyBackupWithErrorMessage:[NSString stringWithFormat:@"%@", message]];
    }];
}

/**
 All contents of Backup directory of app.

 @return Array of contents of Backup director of app.
 */
- (NSArray *)oldBackupFiles {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *message;
    
    NSString *backupDir = [NSString stringWithFormat:@"%@/Backup/", [YGTools documentsDirectoryPath]];
    NSArray *backupFileNames = [fileManager contentsOfDirectoryAtPath:backupDir error:&error];
    if(!backupFileNames && error) {
        message = [NSString stringWithFormat:@"Fail to get contents of backup directory. Error: %@", [error description]];
        NSLog(@"%@", message);
    }
    
    NSMutableArray *backupFilePathes = [[NSMutableArray alloc] init];
    for(NSString *fileName in backupFileNames) {
        [backupFilePathes addObject:[NSString stringWithFormat:@"%@/Backup/%@", [YGTools documentsDirectoryPath], fileName]];
    }
    
    return [backupFilePathes copy];
}

- (void)removeOldBackup:(NSArray *)fileNames successHandler:(void(^)(void))successHander errorHandler:(void(^)(NSString *message))errorHandler {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *message;
    BOOL isSuccess = YES;
    
    for(NSString *fileName in fileNames) {
        if(![fileManager removeItemAtPath:fileName error:&error]) {
            if(error)
                message = [NSString stringWithFormat:@"Fail to remove old backup file. Error: %@", [error description]];
            else
                message = @"Fail to remove old backup file";
            NSLog(@"%@", message);
            isSuccess = NO;
            break;
        }
    }
    
    if(isSuccess)
        successHander();
    else
        errorHandler(message);
}

- (void)copyTempFile:(NSString *)tempPath successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
    
    NSString *targetPath = [NSString stringWithFormat:@"%@/Backup/%@", [YGTools documentsDirectoryPath], [tempPath lastPathComponent]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if([fileManager copyItemAtPath:tempPath toPath:targetPath error:&error]) {
        successHandler();
    } else {
        NSString *message;
        if(error)
            message = [NSString stringWithFormat:@"Fail to copy file from temp to backup directory. Error: %@", [error description]];
        else
            message = @"Fail to copy file from temp to backup directory.";
        NSLog(@"%@", message);
        errorHandler(message);
    }
}

#pragma mark - Restore from local directory

- (void)restore {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    __block NSString *logMessage;
    
    // Check backup directory
    NSString *backupDirPath = [NSString stringWithFormat:@"%@/Backup/", [YGTools documentsDirectoryPath]];
    if(![fileManager fileExistsAtPath:backupDirPath isDirectory:&isDir]) {
        [self createBackupDirAt:backupDirPath];
        return;
    }
    
    // General file name for backup
    NSString *generalFilePath = [self generalBackupFilePath];
    if(!generalFilePath){
        NSLog(@"Local backup is not found.");
        return;
    }

    // Make filenames of backup files
    NSString *databaseFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName];
    NSString *configFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName];
    
    // Copy db
    [self copyBackupFile:databaseFilePath workFileName:kDatabaseName successHandler:^{
        // Copy config
        [self copyBackupFile:configFilePath workFileName:kAppConfigName successHandler:^{
            logMessage = @"Database and config file successfully restored from local backup.";
            NSLog(@"%@", logMessage);
            [YYGDBLog logEvent:logMessage];
            [self.owner notifyRestoreWithSuccess];
        } errorHandler:^(NSString *message) {
            logMessage = [NSString stringWithFormat:@"Fail to restore database and config from local backup. Description: %@", message];
            NSLog(@"%@", logMessage);
            [YYGDBLog logEvent:logMessage];
            [self.owner notifyRestoreWithErrorMessage:message];
        }];
    } errorHandler:^(NSString *message) {
        logMessage = [NSString stringWithFormat:@"Fail to restore database and config from local backup. Description: %@", message];
        NSLog(@"%@", logMessage);
        [YYGDBLog logEvent:logMessage];
        [self.owner notifyRestoreWithErrorMessage:message];
    }];
}

/**
 General file name for current backup. Ex.: "../2018-07-31-11-40-54+0300"

 @return FileName or nil if no backup.
 */
- (NSString *)generalBackupFilePath {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSString *backupDirPath = [NSString stringWithFormat:@"%@/Backup/", [YGTools documentsDirectoryPath]];
    
    YGDirectory *backupDir = [[YGDirectory alloc] initWithPathFull:backupDirPath];
    
    // Set rules
    YGSearchRuleByType *rule1 = [[YGSearchRuleByType alloc] initWithFileSystemObjectType:YGFileSystemObjectTypeFile];
    YGSearchRuleNameMinLength *rule2 = [[YGSearchRuleNameMinLength alloc] initWithNameMinLength:30];
    YGSearchRuleNameIsRegex *rule3 = [[YGSearchRuleNameIsRegex alloc] initWithPattern:@"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite$"];
    
    // TODO: make new rule: for existance two or more paired files +.ledger.db.sqlite.xml +.config.xml
    
    NSArray <YGConfirmingRule> *rules = (NSArray <YGConfirmingRule> *)[NSArray arrayWithObjects:rule1, rule2, rule3, nil];
    
    YGSearchPattern *pattern = [[YGSearchPattern alloc] initWithSearchRules:rules];
    
    // Get all matched objects
    YGFileSystemEnumerator *en = [[YGFileSystemEnumerator alloc] initWithDirectory:backupDir searchPattern:pattern];
    NSArray <YGFileSystemObject *> *backupObjects = [en objects];
    
    NSMutableArray <NSString *> *backupFileNames = [[NSMutableArray alloc] init];
    for(YGFileSystemObject *obj in backupObjects)
        [backupFileNames addObject:obj.pathFull];
    
    // Create result generalized name or nil
    NSString *generalFileName;
    NSInteger backupCount = [backupFileNames count];
    if(backupCount == 0)
        generalFileName = nil;
    else if(backupCount == 1) {
        generalFileName = [backupFileNames firstObject];
        generalFileName = [generalFileName substringToIndex:[generalFileName length]-17];
    }
    else {
        NSArray *sortedFileNames = [[backupFileNames copy] sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return [str1 compare:str2 options:(NSLiteralSearch | NSNumericSearch)];
        }];
      
#ifdef FUNC_DEBUG
        NSLog(@"%@", sortedFileNames);
#endif
        
        generalFileName = [sortedFileNames lastObject];
        generalFileName = [generalFileName substringToIndex:[generalFileName length]-17];
    }

#ifdef FUNC_DEBUG
    NSLog(@"general: %@", generalFileName);
#endif
    
    return generalFileName;
}

- (void)copyBackupFile:(NSString *)backupFilePath workFileName:(NSString *)workFileName successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSString *workFilePath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], workFileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *message;
    
    // If work file exists - remove it
    if([fm fileExistsAtPath:workFilePath]) {
        if([fm removeItemAtPath:workFilePath error:&error]) {
            
        } else {
            if(error)
                message = [NSString stringWithFormat:@"Fail to delete old file removed by backup version. Error: %@", [error description]];
            else
                message = @"Fail to delete old file removed by backup version.";
#ifdef FUNC_DEBUG
            NSLog(@"%@", message);
#endif
            errorHandler(message);
            return;
        }
    }
    
    if([fm copyItemAtPath:backupFilePath toPath:workFilePath error:&error]) {
        successHandler();
    } else {
        if(error)
            message = [NSString stringWithFormat:@"Fail to restore db from local backup to work destination. Error: %@", [error description]];
        else
            message = @"Fail to restore db from local backup to work destination.";
#ifdef FUNC_DEBUG
        NSLog(@"%@", message);
#endif
        errorHandler(message);
    }
}

#pragma mark - Utils

- (void)createBackupDirAt:(NSString *)backupDirPath {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *message;
    
    if(![fileManager createDirectoryAtPath:backupDirPath withIntermediateDirectories:NO attributes:nil error:&error]){
        if(error)
            message = [NSString stringWithFormat:@"Fail to create local backup directory. Error: %@", [error description]];
        else
            message = @"Fail to create local backup directory.";
#ifdef FUNC_DEBUG
        NSLog(@"%@", message);
#endif
    }
}

@end
