#import "YYGLedgerkaDefine.h"

// Flag of app first launch
NSString *const kIsFirstLaunch = @"IsFirstLaunch";

NSString *const kDeviceScreenWidth = @"DeviceScreenWidth";
NSString *const kDeviceScreenHeight = @"DeviceScreenHeight";

// Application build date
NSString *const kAppBuildDate = @"2018-09-26";
NSString *const kAppBuildDateFormat = @"yyyy-MM-dd";

// Database scheme version
int kDatabaseSchemeVersion = 2;

// Application database name
NSString *const kDatabaseName = @"ledger.db.sqlite";

// Application xml config file name
NSString *const kAppConfigName = @"ledger.config.xml";

// Local time in human view format
NSString *const kDateTimeFormat = @"yyyy-MM-dd HH:mm:ss Z";

// Day of year format
NSString *const kDateTimeFormatOnlyDay = @"yyyy-MM-dd";

// Time format
NSString *const kDateTimeFormatOnlyTime = @"HH:mm";

// Timestamp for backup file name
NSString *const kDateTimeFormatForBackupName = @"yyyy-MM-dd-HH-mm-ssZ";

NSString *const kDateMinimum = @"2001-01-01 01:01:01 +0000";

NSString *const kDatabaseSchemeVersionKey = @"DatabaseSchemeVersion";

float kKeyboardAppearanceDelay = 0.6;

// @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite$"
NSString *const kBackupFileNamePattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite"; // +.xml

NSString *const kDropboxAppKey = @"ltzx54gtxldo9sn";

char *const kSQLiteQueue = "com.yanygerasimuk.Ledgerka.sqliteQueue";
char *const kEntitiesQueue = "com.yanygerasimuk.Ledgerka.entitiesQueue";
char *const kReportsQueue = "com.yanygerasimuk.Ledgerka.reportsQueue";
