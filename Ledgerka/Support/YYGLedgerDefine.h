//
//  Define.h
//  Ledger
//
//  Created by Ян on 08/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

// #define APP_STORE 1
// #define DEBUG_PERFORMANCE 1
// #define DEBUG_IS_FIRST_LAUNCH 1
// #define DEBUG_REBUILD_DATABASE 1

extern NSString *const kIsFirstLaunch;

extern NSString *const kDeviceScreenWidth;
extern NSString *const kDeviceScreenHeight;

extern NSString *const kAppBuildDate;
extern NSString *const kAppBuildDateFormat;

extern NSString *const kDatabaseName;
extern NSString *const kDateTimeFormat;
extern NSString *const kAppConfigName;

extern NSString *const kDateTimeFormatOnlyDay;
extern NSString *const kDateTimeFormatOnlyTime;
extern NSString *const kDateTimeFormatForBackupName;
extern NSString *const kDateMinimum;

extern NSString *const kDatabaseSchemeVersionKey;
extern int kDatabaseSchemeVersion;

extern float kKeyboardAppearanceDelay;

extern NSString *const kBackupFileNamePattern;

extern NSString *const kDropboxAppKey;

extern char *const kSQLiteQueue;
extern char *const kEntitiesQueue;
