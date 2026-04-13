//
//  YYGStorageDropbox.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorageDropbox.h"
#import "YGTools.h"
#import "YYGDBTester.h"
#import "YYGLedgerDefine.h"
#import "YYGDBTestDbOpen.h"
#import "YYGDBTestDbFormat.h"
#import "YYGUpdater.h"
#import "YGConfig.h"
#import "YYGConfigDefine.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "YYGDBLog.h"

typedef NS_ENUM(NSInteger, YYGDownloadTaskType) {
    YYGDownloadTaskTypeInfo,
    YYGDownloadTaskTypeRestore
};

@interface YYGStorageDropbox() {
    NSString *p_localGeneralFilePath;
    NSString *p_remoteFileName;
    NSMutableArray *p_remoteFileNames;
    YYGDatabaseInfo *p_backupInfo;
}
@end

@implementation YYGStorageDropbox

- (instancetype)init{
    self = [super init];
    if(self){
        p_localGeneralFilePath = nil;
        p_remoteFileName = nil;
        p_remoteFileNames = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - YYGStoriging

- (BOOL)isNeedLoadView {
    return YES;
}

- (void)checkBackup {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_DOWNLOAD_BACKUP_INFO_MESSAGE", @"Download backup info...")];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSString *searchPath = @"";
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         if (result) {
             
             BOOL isBackupFolderExists = NO;
             for(DBFILESMetadata *meta in result.entries) {
                 if([meta.name isEqualToString:@"Backup"])
                     isBackupFolderExists = YES;
             }
             
             if (!isBackupFolderExists){
                 [self createBackupFolder];
             } else {
                 [self downloadInfoFile];
             }
         } else {
             NSString *title = @"";
             NSString *message = @"";
             NSString *userMessage = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                     userMessage = [message copy];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
                 
                 NSError *nsError = [error nsError];
                 if(nsError){
                     userMessage = [nsError localizedDescription];
                 }
             }
             [self.owner notifyErrorWithTitle:title message:userMessage];
         }
     }];
}

- (void)createBackupFolder {
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[client.filesRoutes createFolderV2:@"/Backup"] setResponseBlock:^(DBFILESCreateFolderResult * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        
        if (result){
            [self.owner notifyIsBackupExists:NO];
        } else {
            NSString *title = @"";
            NSString *message = @"";
            NSString *userMessage = @"";
            if (routeError) {
                // Route-specific request error
                title = @"Route-specific error";
                if ([routeError isPath]) {
                    message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                    userMessage = [message copy];
                }
            } else {
                // Generic request error
                title = @"Generic request error";
                if ([networkError isInternalServerError]) {
                    DBRequestInternalServerError *internalServerError = [networkError asInternalServerError];
                    message = [NSString stringWithFormat:@"%@", internalServerError];
                } else if ([networkError isBadInputError]) {
                    DBRequestBadInputError *badInputError = [networkError asBadInputError];
                    message = [NSString stringWithFormat:@"%@", badInputError];
                } else if ([networkError isAuthError]) {
                    DBRequestAuthError *authError = [networkError asAuthError];
                    message = [NSString stringWithFormat:@"%@", authError];
                } else if ([networkError isRateLimitError]) {
                    DBRequestRateLimitError *rateLimitError = [networkError asRateLimitError];
                    message = [NSString stringWithFormat:@"%@", rateLimitError];
                } else if ([networkError isHttpError]) {
                    DBRequestHttpError *genericHttpError = [networkError asHttpError];
                    message = [NSString stringWithFormat:@"%@", genericHttpError];
                } else if ([networkError isClientError]) {
                    DBRequestClientError *genericLocalError = [networkError asClientError];
                    message = [NSString stringWithFormat:@"%@", genericLocalError];
                }
                
                NSError *nsError = [networkError nsError];
                if(nsError){
                    userMessage = [nsError localizedDescription];
                }
            }
            [self.owner notifyErrorWithTitle:title message:userMessage];
        }
    }];
}

- (void)downloadInfoFile {
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    NSString *searchPath = @"/Backup/";
    
    __weak YYGStorageDropbox *weakSelf = self;
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         YYGStorageDropbox *strongSelf = weakSelf;
         if(strongSelf) {
             if (result) {
                 
                 // 1. Fill files list
                 for(DBFILESMetadata *meta in result.entries) {
                     //                 NSLog(@"meta: %@", meta);
                     [strongSelf->p_remoteFileNames addObject:meta.name];
                 }
                 
                 // 2. Is backup exists and get name
                 NSString *fileName = [YYGStorage backupFileNameFrom:strongSelf->p_remoteFileNames];
                 //             NSLog(@"backupFileName: %@", fileName);
                 if(fileName){
                     strongSelf->p_remoteFileName = fileName;
                     
                     // 3. Download info file and parse it
                     NSString *sourcePath = [NSString stringWithFormat:@"/Backup/%@.xml", fileName];
                     NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.xml", NSTemporaryDirectory(), fileName]];
                     [strongSelf downloadFileFrom:sourcePath toDestination:targetURL forTask:YYGDownloadTaskTypeInfo];
                 } else {
                     [strongSelf.owner notifyIsBackupExists:NO];
                 }
             } else {
                 NSString *title = @"";
                 NSString *message = @"";
                 NSString *userMessage = @"";
                 if (routeError) {
                     // Route-specific request error
                     title = @"Route-specific error";
                     if ([routeError isPath]) {
                         message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                         userMessage = [message copy];
                     }
                 } else {
                     // Generic request error
                     title = @"Generic request error";
                     if ([error isInternalServerError]) {
                         DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                         message = [NSString stringWithFormat:@"%@", internalServerError];
                     } else if ([error isBadInputError]) {
                         DBRequestBadInputError *badInputError = [error asBadInputError];
                         message = [NSString stringWithFormat:@"%@", badInputError];
                     } else if ([error isAuthError]) {
                         DBRequestAuthError *authError = [error asAuthError];
                         message = [NSString stringWithFormat:@"%@", authError];
                     } else if ([error isRateLimitError]) {
                         DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                         message = [NSString stringWithFormat:@"%@", rateLimitError];
                     } else if ([error isHttpError]) {
                         DBRequestHttpError *genericHttpError = [error asHttpError];
                         message = [NSString stringWithFormat:@"%@", genericHttpError];
                     } else if ([error isClientError]) {
                         DBRequestClientError *genericLocalError = [error asClientError];
                         message = [NSString stringWithFormat:@"%@", genericLocalError];
                     }
                     
                     NSError *nsError = [error nsError];
                     if(nsError){
                         userMessage = [nsError localizedDescription];
                     }
                 }
                 [strongSelf.owner notifyErrorWithTitle:title message:userMessage];
             }
         } // if(strongSelf)
     }];
}

- (YYGDatabaseInfo *)backupInfo {
    return p_backupInfo;
}

#pragma mark - Restore backup from Dropbox

- (void)restore {
    
    __block NSString *logMessage;
    __weak YYGStorageDropbox *weakSelf = self;
    
    // Restore db file
    [self restoreRemoteFile:p_remoteFileName successHandler:^(void) {
        YYGStorageDropbox *strongSelf = weakSelf;
        if(strongSelf) {
            // Neighter exists remote config file or not - restore is success
            logMessage = @"Database successfully restored from Dropbox.";
            [YYGDBLog logEvent:logMessage];
            NSLog(@"%@", logMessage);
            
            // Try to restore config file
            NSString *configFile = [NSString stringWithFormat:@"%@.config.xml", [strongSelf->p_remoteFileName substringToIndex:[strongSelf->p_remoteFileName length]-10]];
            [self restoreRemoteFile:configFile successHandler:^(){
                logMessage = @"Application config file successfully restored from Dropbox.";
                NSLog(@"%@", logMessage);
                [YYGDBLog logEvent:logMessage];
                [strongSelf.owner notifyRestoreWithSuccess];
            } errorHandler:^(NSString *message){
                logMessage = [NSString stringWithFormat:@"Failed to restore application config from Dropbox. Description: %@", message];
                NSLog(@"%@", logMessage);
                [YYGDBLog logEvent:logMessage];
                
                // Set initial keys for environment version
                YGConfig *config = [YGTools config];
                [config setValue:@1 forKey:kConfigEnvironmentMajorVersion];
                [config setValue:@1 forKey:kConfigEnvironmentMinorVersion];
                [config setValue:@13 forKey:kConfigEnvironmentBuildVersion];
                
                [strongSelf.owner notifyRestoreWithSuccess];
            }];
        }
    } errorHandler:^(NSString *message) {
        YYGStorageDropbox *strongSelf = weakSelf;
        if(strongSelf) {
            logMessage = [NSString stringWithFormat:@"Failed to restore database from Dropbox. Description: %@", message];
            NSLog(@"%@", logMessage);
            [YYGDBLog logEvent:logMessage];
            [self.owner notifyRestoreWithErrorMessage:message];
            
            // TODO: Need addtional clearing?
        }
    }];
}

- (void)restoreRemoteFile:(NSString *)fileName successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_DOWNLOAD_BACKUP_MESSAGE", @"Download backup...")];
    
    NSURL *dbDestination = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileName]];

    NSString *remoteFilePath = [NSString stringWithFormat:@"/Backup/%@", fileName];
    [self downloadFileFrom:remoteFilePath toDestination:dbDestination successHandler:^(NSURL *dbFile) {
        [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_TEST_BACKUP_MESSAGE", @"Test backup...")];
        
        // If downloaded file is database - test it
        if([[dbFile absoluteString] hasSuffix:@".sqlite"]) {
            [self testDatabase:[dbFile absoluteString] successHandler:^{
                // fallthrough
                NSLog(@"Downloaded database passes tests.");
            } errorHandler:^(NSString *failTestMessage) {
                NSLog(@"Downloaded database fails tests.");
                [self removeFile:[dbFile absoluteString] successHandler:^{
                    errorHandler(failTestMessage);
                } errorHandler:^(NSString *failRemoveTempMessage) {
                    errorHandler([NSString stringWithFormat:@"%@. %@.", failTestMessage, failRemoveTempMessage]);
                }];
            }];
        }
        
        NSString *workFileName;
        if([[dbFile absoluteString] hasSuffix:@".db.sqlite"])
            workFileName = kDatabaseName;
        else // ".config.xml" or ".db.sqlite.xml"
            workFileName = kAppConfigName;
        
        [self restoreDownloadedFile:dbFile withFileName:workFileName successHandler:^{
            successHandler();
        } errorHandler:^(NSString *message) {
            errorHandler(message);
        }];
    } errorHandler:^(NSString *message) {
        //[self.owner notifyRestoreWithErrorMessage:message];
        errorHandler(message);
    }];
}

- (void)testDatabase:(NSString *)fileName successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
    
    YYGDBTestDbFormat *testFormat = [[YYGDBTestDbFormat alloc] init];
    YYGDBTestDbOpen *testOpen = [[YYGDBTestDbOpen alloc] init];
    
    NSArray <id<YYGDBTesting>> *tests = [NSArray arrayWithObjects:testFormat, testOpen, nil];
    YYGDBTester *tester = [[YYGDBTester alloc] initWithDbFile:fileName tests:tests];
    
    if ([tester testDbFile]){
        successHandler();
    } else {
        NSString *message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"DROPBOX_CAN_NOT_RESTORE_DB_MESSAGE", @"Can not restore database from remote backup."), [tester messageOfFailedTests]];
        errorHandler(message);
    }
}

- (void)removeFile:(NSString *)fileName successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {

    NSFileManager *fileMananger = [NSFileManager defaultManager];
    NSError *error;
    if(![fileMananger removeItemAtPath:fileName error:&error]){
        NSString *message;
        if(error)
            message = [NSString stringWithFormat:@"Fail to remove file unpassed tests. Error: %@", [error description]];
        else
            message = [NSString stringWithFormat:@"Fail to remove file unpassed tests."];
        errorHandler(message);
    } else {
        successHandler();
    }
}

- (void)restoreDownloadedFile:(NSURL *)downloadedFile withFileName:(NSString *)fileName successHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler {
    
    NSLog(@"Restore downloaded file: %@", downloadedFile);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *message;
    
    NSString *sourcePath = [downloadedFile absoluteString];
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], fileName];
    NSString *tempPath = [NSString stringWithFormat:@"%@%@.temp", NSTemporaryDirectory(), fileName];
    
    //NSLog(@"Pathes: \n\nsource: %@ \ntarget: %@ \ntemp: %@\n", sourcePath, targetPath, tempPath);

    // Move old, replaced file to temp
    if([fileManager fileExistsAtPath:targetPath]){
        if(![fileManager moveItemAtPath:targetPath toPath:tempPath error:&error]) {
            if(error)
                message = [NSString stringWithFormat:@"Fail to move old, replaced file to temp path. Error: %@", [error description]];
            else
                message = @"Fail to move old, replaced file to temp path.";
            NSLog(@"%@", message);
            errorHandler(message);
        }
    }

    // Move downloaded backup file to work destination
    if(![fileManager moveItemAtPath:sourcePath toPath:targetPath error:&error]) {
        if(error) {
            message = [NSString stringWithFormat:@"Fail to move file. Error: %@", [error description]];
        } else {
            message = @"Fail to move file.";
        }
        NSLog(@"%@", message);
        
        // Restore work file from temp
        NSLog(@"Try to restore work version of file from temp.");
        if(![fileManager moveItemAtPath:tempPath toPath:targetPath error:&error]) {
            if(error) {
                message = [NSString stringWithFormat:@"Fail to to restore work version of file from temp. Error: %@", [error description]];
            } else {
                message = @"Fail to restore work version of file from temp.";
            }
            NSLog(@"%@", message);
        }
        errorHandler(message);
    } else {
        // Delete temp file with old file
        if(![fileManager removeItemAtPath:tempPath error:&error]) {
            if(error) {
                message = [NSString stringWithFormat:@"Fail to remove old, replaced file from temp destination. Error: %@", [error description]];
            } else {
                message = @"Fail to remove old, replaced file from temp destination.";
            }
            NSLog(@"%@", message);
        }
        successHandler();
    }
}

- (BOOL) replaceOldFile:(NSString *)oldFilePath onNewFile:(NSString *)newFilePath {
    
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    
    // 1. Rename work db file to temp name
    NSString *oldFileTempPath = [NSString stringWithFormat:@"%@.%@.tmp", oldFilePath, [[NSUUID UUID] UUIDString]];
    NSError *error = nil;
    if (![fileMananger moveItemAtPath:oldFilePath toPath:oldFileTempPath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not rename work db file.");
        return NO;
    }
    
    // 2. Rename backup db file to work db name
    if(![fileMananger moveItemAtPath:newFilePath toPath:oldFilePath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not rename backup db file.");
        
        // rollback
        // TODO: Need to do something?
        
        return NO;
    }
    
    // 3. Delete ex work db file with temp name
    if(![fileMananger removeItemAtPath:oldFileTempPath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not remove old work db file.");
        
        // It is not serious problem :)
    }
    
    return YES;
}


#pragma mark - Backup db to Dropbox

- (void)backup:(NSString *)generalFilePath {
    
    p_localGeneralFilePath = generalFilePath;
    
    NSString *databaseFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName];
    NSString *descriptionFilePath = [NSString stringWithFormat:@"%@.%@.xml", generalFilePath, kDatabaseName];
    NSString *configFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName];
    
    __block NSString *logMessage;
    [self uploadFile:databaseFilePath successHandler:^{
        [self uploadFile:descriptionFilePath successHandler:^{
            [self uploadFile:configFilePath successHandler:^{
                logMessage = @"Database, description and config files successfully backuped to Dropbox.";
                NSLog(@"%@", logMessage);
                [YYGDBLog logEvent:logMessage];
                [self notifyUploadedWithSuccess];
            } errorHandler:^(NSString *message) {
                logMessage = [NSString stringWithFormat:@"Failed to backup config file to Dropbox. Description: %@", message];
                NSLog(@"%@", logMessage);
                [YYGDBLog logEvent:logMessage];
                [self notifyUploadedWithError:message];
            }];
        } errorHandler:^(NSString *message) {
            logMessage = [NSString stringWithFormat:@"Failed to backup description file to Dropbox. Description: %@", message];
            NSLog(@"%@", logMessage);
            [YYGDBLog logEvent:logMessage];
            [self notifyUploadedWithError:message];
        }];
    } errorHandler:^(NSString *message) {
        logMessage = [NSString stringWithFormat:@"Failed to backup database to Dropbox. Description: %@", message];
        NSLog(@"%@", logMessage);
        [YYGDBLog logEvent:logMessage];
        [self notifyUploadedWithError:message];
    }];
}

/**
 @warning Callback to owner will be at checkBackup().
 */
- (void)notifyUploadedWithSuccess {
    
    // Clear temp local and remote files
    [self clearLocalTempWith:p_localGeneralFilePath];
    [self clearRemoteOldBackupsWithout:p_localGeneralFilePath];;
    
    // Clear shared
    p_localGeneralFilePath = nil;
    p_remoteFileName = nil;
    [p_remoteFileNames removeAllObjects];
    
    // Update backup info
    [self checkBackup];
}

// Хорошо бы передать ошибку...
- (void)notifyUploadedWithError:(NSString *)message {
    
    // Clear temp local and remote files
    [self clearLocalTempWith:p_localGeneralFilePath];
    [self clearRemoteUploadedWithErrorsWith:p_localGeneralFilePath];
    
    // Callback to owner immediatly
    [self.owner notifyBackupWithErrorMessage:message];
}

- (void)clearLocalTempWith:(NSString *)generalFilePath {
    
    NSString *databaseFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName];
    NSString *descriptionFilePath = [NSString stringWithFormat:@"%@.%@.xml", generalFilePath, kDatabaseName];
    NSString *configFilePath = [NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // database file
    if([fileManager fileExistsAtPath:databaseFilePath]) {
        if(![fileManager removeItemAtPath:databaseFilePath error:&error]) {
            NSString *message;
            if(error)
                message = [NSString stringWithFormat:@"Fail to remove local, temp database file. Error: %@", [error description]];
            else
                message = @"Fail to remove local, temp database file.";
            NSLog(@"%@", message);
        }
    }
    
    // description file
    if([fileManager fileExistsAtPath:descriptionFilePath]) {
        if(![fileManager removeItemAtPath:descriptionFilePath error:&error]) {
            NSString *message;
            if(error)
                message = [NSString stringWithFormat:@"Fail to remove local, temp description file. Error: %@", [error description]];
            else
                message = @"Fail to remove local, temp description file.";
            NSLog(@"%@", message);
        }
    }
    
    // config file
    if([fileManager fileExistsAtPath:configFilePath]) {
        if(![fileManager removeItemAtPath:configFilePath error:&error]) {
            NSString *message;
            if(error)
                message = [NSString stringWithFormat:@"Fail to remove local, temp config file. Error: %@", [error description]];
            else
                message = @"Fail to remove local, temp config file.";
            NSLog(@"%@", message);
        }
    }
}

- (void)clearRemoteOldBackupsWithout:(NSString *)generalFilePath {
    
    // Check
    if ([p_remoteFileNames count] == 0)
        return;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    NSMutableArray <DBFILESDeleteArg *> *args = [[NSMutableArray alloc] init];
    
    // New backup files
    NSString *databaseFileName = [[NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName] lastPathComponent];
    NSString *descriptionFileName = [[NSString stringWithFormat:@"%@.%@.xml", generalFilePath, kDatabaseName] lastPathComponent];
    NSString *configFileName = [[NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName] lastPathComponent];
    
    // Make array for files to delete
    for(NSString *name in p_remoteFileNames){
        if(![name isEqualToString:databaseFileName]
           && ![name isEqualToString:descriptionFileName]
           && ![name isEqualToString:configFileName]){
            DBFILESDeleteArg *arg = [[DBFILESDeleteArg alloc] initWithPath:[@"/Backup/" stringByAppendingString:name]];
            [args addObject:arg];
        }
    }
    
    // Delete if old and unneccessarily files exists
    if([args count] > 0){
        [client.filesRoutes deleteBatch:[args copy]];
    }
}

- (void)clearRemoteUploadedWithErrorsWith:(NSString *)generalFilePath {
    
    // Check
    if (!p_localGeneralFilePath)
        return;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    NSMutableArray <DBFILESDeleteArg *> *args = [[NSMutableArray alloc] init];
    
    // Failed backup files
    NSString *databaseFileName = [[NSString stringWithFormat:@"%@.%@", generalFilePath, kDatabaseName] lastPathComponent];
    NSString *descriptionFileName = [[NSString stringWithFormat:@"%@.%@.xml", generalFilePath, kDatabaseName] lastPathComponent];
    NSString *configFileName = [[NSString stringWithFormat:@"%@.%@", generalFilePath, kAppConfigName] lastPathComponent];
    
    // Add files to array for delete
    [args addObject:[[DBFILESDeleteArg alloc] initWithPath:[NSString stringWithFormat:@"/Backup/%@", databaseFileName]]];
    [args addObject:[[DBFILESDeleteArg alloc] initWithPath:[NSString stringWithFormat:@"/Backup/%@", descriptionFileName]]];
    [args addObject:[[DBFILESDeleteArg alloc] initWithPath:[NSString stringWithFormat:@"/Backup/%@", configFileName]]];
    
    // Delete failed files
    [client.filesRoutes deleteBatch:[args copy]];
}

- (void)uploadFile:(NSString *)fileName successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString *message))errorHandler {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_UPLOAD_BACKUP_MESSAGE", @"Upload backup...")];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    // Remote path
    NSString *shortName = [fileName lastPathComponent];
    NSString *targetPath = [@"/Backup/" stringByAppendingString:shortName];
    
    [[[client.filesRoutes uploadData:targetPath
                                mode:mode
                          autorename:@(NO)
                      clientModified:nil
                                mute:@(NO)
                      propertyGroups:nil
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
          if (result) {
              //NSLog(@"%@\n", result);
              successHandler();
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
              NSString *message = nil;
              if (networkError){
                  NSString *errorUserInfo = [[networkError nsError] localizedDescription];
                  if (errorUserInfo)
                      message = errorUserInfo;
              }
              else if(routeError){
                  message = [routeError description];
              }
              errorHandler(message);
          }
      }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
          //NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
      }];
}


- (void)uploadBackupFile:(NSString *)fileName {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    NSString *shortFileName = [fileName lastPathComponent];
    
    NSString *targetFileName = [@"/Backup/" stringByAppendingString:shortFileName];
    
    [[[client.filesRoutes uploadData:targetFileName
                                mode:mode
                          autorename:@(YES)
                      clientModified:nil
                                mute:@(NO)
                      propertyGroups:nil
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
          if (result) {
              NSLog(@"%@\n", result);
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
          NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
      }];

}

- (void)downloadFileFrom:(NSString *)downloadPath toDestination:(NSURL *)destinationUrl successHandler:(void (^)(NSURL *downloadedUrl))successHandler errorHandler:(void (^)(NSString *message))errorHandler{
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[[client.filesRoutes
       downloadUrl:downloadPath
       overwrite:YES
       destination:destinationUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError, NSURL *destination) {
          
          if (result) {
              //NSLog(@"%@\n", result);
//              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
//              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              //NSLog(@"%@\n", dataStr);
              
              successHandler(destinationUrl);
          } else {
              errorHandler([NSString stringWithFormat:@"%@ %@", routeError, networkError]);
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }]
     setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
         // NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
     }];
}

/**
 Download file from dropbox. Wrapper on dropbox API.

 @param downloadPath String like @"/test/path/in/Dropbox/account/my_file.txt"
 @param destinationUrl Full file name on local.
 @param taskType Task type: download info or download backup
 */
- (void)downloadFileFrom:(NSString *)downloadPath toDestination:(NSURL *)destinationUrl forTask:(YYGDownloadTaskType)taskType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    __weak YYGStorageDropbox *weakSelf = self;
    
    [[[client.filesRoutes
       downloadUrl:downloadPath
       overwrite:YES
       destination:destinationUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError, NSURL *destination) {
          
          YYGStorageDropbox *strongSelf = weakSelf;
          if(strongSelf) {
              if (result) {
                  //#ifdef FUNC_DEBUG
                  //              NSLog(@"%@\n", result);
                  //#endif
                  //              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
                  //              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                  //#ifdef FUNC_DEBUG
                  //              NSLog(@"%@\n", dataStr);
                  //#endif
                  
                  switch (taskType) {
                      case YYGDownloadTaskTypeInfo:
#ifdef FUNC_DEBUG
                          NSLog(@"destinationURL: %@", destinationUrl);
#endif
                          
                          strongSelf->p_backupInfo = [YYGStorage backupInfoFrom:[destinationUrl absoluteString]];
                          [YYGStorage removeFileAt:[destinationUrl absoluteString]];
                          [strongSelf.owner notifyIsBackupExists:YES];
                          break;
                      case YYGDownloadTaskTypeRestore:
                          //                      [self notifyRestoreDbFile:destinationUrl];
                          break;
                      default:
                          @throw [NSException exceptionWithName:@"Unknown download type" reason:@"downloadFileFrom:toDestination:forTask can not execute for unknown type" userInfo:nil];
                  }
                  
              } else {
                  NSLog(@"%@\n%@\n", routeError, networkError);
              }
              
          }
      }]
     setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
#ifdef FUNC_DEBUG
          NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
#endif
      }];
}

@end
