//
//  YYGBackupViewModel.m
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGBackupViewModel.h"
#import "YYGLocalBackupViewModel.h"
#import "YYGDropboxBackupViewModel.h"
#import "YYGUpdater.h"

@implementation YYGBackupViewModel

+ (id<YYGBackupViewModelable>)viewModelWith:(YYGStorageType)type {
    id<YYGBackupViewModelable> viewModel;
    switch(type) {
        case YYGStorageTypeLocal:
            viewModel = [[YYGLocalBackupViewModel alloc] init];
            break;
        case YYGStorageTypeDropbox:
            viewModel = [[YYGDropboxBackupViewModel alloc] init];
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGBackupViewModel.viewModelWith: fails." reason:@"Unknown storage type" userInfo:nil];
    }
    return viewModel;
}

- (YYGDatabaseInfo *)workDbInfo {
    return [[YYGDatabaseInfo alloc] initWithWorkDb];
}

- (YYGDatabaseInfo *)backupDbInfo {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}

- (NSString *)restoreAlertTitle {
    return NSLocalizedString(@"WARNING_ALERT_CONTROLLER_TITLE", @"Warning");
}

- (NSString *)restoreAlertMessage {
    return  NSLocalizedString(@"DB_REPLACEMENT_WHEN_RESTORE_MESSAGE", @"В процессе восстановления текущая база данных будет заменена на архивную.");
}

- (NSString *)restoreAlertButtonTitle {
    return NSLocalizedString(@"RESTORE_ALERT_ITEM_TITLE", @"Restore");
}

- (void)update {
    [self notifyMessage:@"Check updates..."];
    YYGUpdater *updater = [[YYGUpdater alloc] init];
    [updater checkEnvironment];
}

#pragma mark - YYGStorageOwning proxies

- (void)notifyIsBackupExists:(BOOL)isBackupExists {
    [self.notifyIsBackupExistsSubject sendNext:@(isBackupExists)];
}

- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message {
    [self.notifyErrorWithTitleAndMessageSubject sendNext:RACTuplePack(title, message)];
}

- (void)notifyMessage:(NSString *)message {
    [self.notifyMessageSubject sendNext:message];
}

- (void)notifyBackupWithSuccess {
    [self.notifyBackupWithSuccessSubject sendNext:nil];
}

- (void)notifyBackupWithErrorMessage:(NSString *)message {
    [self.notifyBackupWithErrorMessageSubject sendNext:message];
}

- (void)notifyRestoreWithSuccess {
    [self update];
    [self.notifyRestoreWithSuccessSubject sendNext:nil];
}

- (void)notifyRestoreWithErrorMessage:(NSString *)errorMessage {
    [self.notifyRestoreWithErrorMessageSubject sendNext:errorMessage];
}

#pragma mark - Init reactive subjects

- (RACSubject *)notifyIsBackupExistsSubject {
    if(!_notifyIsBackupExistsSubject) {
        _notifyIsBackupExistsSubject = [[RACSubject alloc] init];
    }
    return _notifyIsBackupExistsSubject;
}

- (RACSubject *)notifyErrorWithTitleAndMessageSubject {
    if(!_notifyErrorWithTitleAndMessageSubject) {
        _notifyErrorWithTitleAndMessageSubject = [[RACSubject alloc] init];
    }
    return _notifyErrorWithTitleAndMessageSubject;
}

- (RACSubject *)notifyMessageSubject {
    if(!_notifyMessageSubject) {
        _notifyMessageSubject = [[RACSubject alloc] init];
    }
    return _notifyMessageSubject;
}

- (RACSubject *)notifyBackupWithSuccessSubject {
    if(!_notifyBackupWithSuccessSubject) {
        _notifyBackupWithSuccessSubject = [[RACSubject alloc] init];
    }
    return _notifyBackupWithSuccessSubject;
}

- (RACSubject *)notifyBackupWithErrorMessageSubject {
    if(!_notifyBackupWithErrorMessageSubject) {
        _notifyBackupWithErrorMessageSubject = [[RACSubject alloc] init];
    }
    return _notifyBackupWithErrorMessageSubject;
}

- (RACSubject *)notifyRestoreWithSuccessSubject {
    if(!_notifyRestoreWithSuccessSubject) {
        _notifyRestoreWithSuccessSubject = [[RACSubject alloc] init];
    }
    return _notifyRestoreWithSuccessSubject;
}

- (RACSubject *)notifyRestoreWithErrorMessageSubject {
    if(!_notifyRestoreWithErrorMessageSubject) {
        _notifyRestoreWithErrorMessageSubject = [[RACSubject alloc] init];
    }
    return _notifyRestoreWithErrorMessageSubject;
}

@end
