//
//  YYGLocalBackupViewModel.h
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGBackupViewModel.h"

@interface YYGLocalBackupViewModel : YYGBackupViewModel <YYGBackupViewModelable>

- (instancetype)init;

- (NSString *)title;
- (BOOL)hasRightNavBarButton;

- (YYGDatabaseInfo *)workDbInfo;
- (YYGDatabaseInfo *)backupDbInfo;

- (void)checkBackup;
- (BOOL)isNeedLoadView;
- (void)backup;
- (void)restore;
@end
