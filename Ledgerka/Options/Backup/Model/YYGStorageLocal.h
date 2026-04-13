//
//  YYGStorageLocal.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorage.h"
#import "YYGDatabaseInfo.h"

@interface YYGStorageLocal : YYGStorage <YYGStoraging>

- (BOOL)isNeedLoadView;
- (void)checkBackup;
- (YYGDatabaseInfo *)backupInfo;
- (void)backup:(NSString *)generalFilePath;
- (void)restore;
@end
