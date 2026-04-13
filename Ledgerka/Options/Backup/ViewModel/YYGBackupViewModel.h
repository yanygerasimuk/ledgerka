//
//  YYGBackupViewModel.h
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGStorage.h"
#import "YYGDatabaseInfo.h"
#import <ReactiveObjC/ReactiveObjC.h>

@protocol YYGBackupViewModelable

// Self type
@property (assign, nonatomic) YYGStorageType type;

// Storage events
@property (nonatomic, strong) RACSubject *notifyIsBackupExistsSubject;
@property (nonatomic, strong) RACSubject *notifyErrorWithTitleAndMessageSubject;
@property (nonatomic, strong) RACSubject *notifyMessageSubject;
@property (nonatomic, strong) RACSubject *notifyBackupWithSuccessSubject;
@property (nonatomic, strong) RACSubject *notifyBackupWithErrorMessageSubject;
@property (nonatomic, strong) RACSubject *notifyRestoreWithSuccessSubject;
@property (nonatomic, strong) RACSubject *notifyRestoreWithErrorMessageSubject;

// Methods
- (NSString *)title;
- (BOOL)hasRightNavBarButton;
- (YYGDatabaseInfo *)workDbInfo;
- (YYGDatabaseInfo *)backupDbInfo;
- (void)checkBackup;
- (BOOL)isNeedLoadView;
- (void)backup;
- (NSString *)restoreAlertTitle;
- (NSString *)restoreAlertMessage;
- (NSString *)restoreAlertButtonTitle;
- (void)restore;
- (void)update;
@end

@interface YYGBackupViewModel : NSObject

// Fabric
+ (id<YYGBackupViewModelable>)viewModelWith:(YYGStorageType)type;

@property (assign, nonatomic) YYGStorageType type;

@property (nonatomic, strong) RACSubject *notifyIsBackupExistsSubject;
@property (nonatomic, strong) RACSubject *notifyErrorWithTitleAndMessageSubject;
@property (nonatomic, strong) RACSubject *notifyMessageSubject;
@property (nonatomic, strong) RACSubject *notifyBackupWithSuccessSubject;
@property (nonatomic, strong) RACSubject *notifyBackupWithErrorMessageSubject;
@property (nonatomic, strong) RACSubject *notifyRestoreWithSuccessSubject;
@property (nonatomic, strong) RACSubject *notifyRestoreWithErrorMessageSubject;

- (YYGDatabaseInfo *)workDbInfo;
- (YYGDatabaseInfo *)backupDbInfo;

- (NSString *)restoreAlertTitle;
- (NSString *)restoreAlertMessage;
- (NSString *)restoreAlertButtonTitle;

- (void)update;

- (void)notifyIsBackupExists:(BOOL)isBackupExists;
- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message;
- (void)notifyMessage:(NSString *)message;
- (void)notifyBackupWithSuccess;
- (void)notifyBackupWithErrorMessage:(NSString *)message;
- (void)notifyRestoreWithSuccess;
- (void)notifyRestoreWithErrorMessage:(NSString *)errorMessage;
@end
