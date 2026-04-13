//
//  YGDBManager.h
//  Ledger
//
//  Created by Ян on 06/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGDBManager : NSObject

+ (YGDBManager *)sharedInstance;

- (instancetype)init;

- (BOOL)isDatabaseFileExists;
- (void)createDatabase;
- (void)deleteDatabaseFile;
- (NSString *)lastOperation;
- (NSString *)databaseFullName;

@end
