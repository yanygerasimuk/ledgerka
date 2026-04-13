//
//  YYGDBLog.m
//  Ledger
//
//  Created by Ян on 01/08/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDBLog.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGDBManager.h"

@implementation YYGDBLog

+ (void)logEvent:(NSString *)event {
    
    YGDBManager *dm = [YGDBManager sharedInstance];
    if(![dm isDatabaseFileExists])
        return;
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    @try {
        
        NSDate *now = [NSDate date];
        
        NSArray  *arrEvent = [NSArray
                              arrayWithObjects:[YGTools stringFromDate:now],
                              [NSNumber numberWithDouble:[now timeIntervalSince1970]],
                              event,
                              nil];
        
        
        NSString *insertSQL = @"INSERT INTO log (created, created_unix, message) VALUES (?, ?, ?);";
        
        [sqlite addRecord:arrEvent insertSQL:insertSQL];
    }
    @catch (NSException *exception) {
        NSLog(@"Fail to log in dbLog. Exception: %@", [exception description]);
    }
}

@end
