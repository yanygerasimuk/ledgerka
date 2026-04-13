//
//  YYGStorage.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYGDatabaseInfo.h"

typedef NS_ENUM(NSInteger, YYGStorageType) {
    YYGStorageTypeLocal,
    YYGStorageTypeDropbox
};

@protocol YYGStorageOwning

- (void)notifyIsBackupExists:(BOOL)isBackupExists;
- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message;
- (void)notifyMessage:(NSString *)message;
- (void)notifyBackupWithErrorMessage:(NSString *)message;
- (void)notifyRestoreWithSuccess;
- (void)notifyRestoreWithErrorMessage:(NSString *)errorMessage;
@end

@protocol YYGStoraging

@property (assign, nonatomic) YYGStorageType type;
@property (weak, nonatomic) id<YYGStorageOwning> owner;
- (BOOL)isNeedLoadView;
- (void)checkBackup;
- (YYGDatabaseInfo *)backupInfo;
- (void)backup:(NSString *)fileName;
- (void)restore;
@end

@interface YYGStorage: NSObject

+ (id<YYGStoraging>)storageWithType:(YYGStorageType) type;
+ (NSString *)backupFileNameFrom:(NSMutableArray *)fileNames;
+ (NSArray *)filteredFileNames:(NSArray *)fileNames;
+ (YYGDatabaseInfo *)backupInfoFrom:(NSString *)fileName;
+ (void)removeFileAt:(NSString *)fileName;
+ (BOOL)isDirectoryExistsAt:(NSString *)path;

@property (assign, nonatomic) YYGStorageType type;
@property (weak, nonatomic) id<YYGStorageOwning> owner;
@end
