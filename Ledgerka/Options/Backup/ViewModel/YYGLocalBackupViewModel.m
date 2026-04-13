//
//  YYGLocalBackupViewModel.m
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGLocalBackupViewModel.h"
#import "YYGBackuper.h"

@interface YYGLocalBackupViewModel () <YYGStorageOwning> {
    id<YYGStoraging> p_storage;
}
@end

@implementation YYGLocalBackupViewModel

- (instancetype)init {
    self = [super init];
    if(self) {
        self.type = YYGStorageTypeLocal;
        p_storage = [YYGStorage storageWithType:self.type];
        p_storage.owner = self;
    }
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"LOCAL_BACKUP_FORM_TITLE", @"Title of Local backup form");
}

- (BOOL)hasRightNavBarButton {
    return NO;
}

- (YYGDatabaseInfo *)workDbInfo {
    return [super workDbInfo];
}

- (YYGDatabaseInfo *)backupDbInfo {
    return [p_storage backupInfo];
}

- (void)checkBackup {
    [p_storage checkBackup];
}

- (BOOL)isNeedLoadView {
    return [p_storage isNeedLoadView];
}

- (void)backup {
    // Make snapshot db, info and xml files
    YYGBackuper *backuper = [[YYGBackuper alloc] init];
    __weak YYGLocalBackupViewModel *weakSelf = self;
    [backuper backupWithSuccessHandler:^{
        YYGLocalBackupViewModel *strongSelf = weakSelf;
        if(strongSelf) {
            // Upload backup to the storage
            [strongSelf->p_storage backup:backuper.generalFilePath];
        }
    } errorHandler:^(NSString *message) {
        YYGLocalBackupViewModel *strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf notifyBackupWithErrorMessage:message];
        }
    }];
}

- (void)restore {
    [p_storage restore];
}

#pragma mark - YYGStorageOwning proxies

- (void)notifyIsBackupExists:(BOOL)isBackupExists {
    [super notifyIsBackupExists:isBackupExists];
}

- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message {
    [super notifyErrorWithTitle:title message:message];
}

- (void)notifyMessage:(NSString *)message {
    [super notifyMessage:message];
}

- (void)notifyBackupWithSuccess {
    [super notifyBackupWithSuccess];
}

- (void)notifyBackupWithErrorMessage:(NSString *)message {
    [super notifyBackupWithErrorMessage:message];
}

- (void)notifyRestoreWithSuccess {
    [super notifyRestoreWithSuccess];
}

- (void)notifyRestoreWithErrorMessage:(NSString *)errorMessage {
    [super notifyRestoreWithErrorMessage:errorMessage];
}

@end
