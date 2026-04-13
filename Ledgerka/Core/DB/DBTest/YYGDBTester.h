//
//  YYGDBTester.h
//  Ledger
//
//  Created by Ян on 28.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYGDBTestOwning
- (NSString *)dbFileFullName;
@end

@protocol YYGDBTesting
@property(weak, nonatomic) id<YYGDBTestOwning> owner;
@property(strong, nonatomic) NSString *rule;
@property(strong, nonatomic) NSString *message;
@property(assign, nonatomic) BOOL isContinue;
- (BOOL)run;
@end

@interface YYGDBTester : NSObject <YYGDBTestOwning>

@property (strong, nonatomic) NSMutableArray <id<YYGDBTesting>> *passedTests;
@property (strong, nonatomic) NSMutableArray <id<YYGDBTesting>> *failedTests;

/// Base init
- (instancetype)initWithDbFile:(NSString *)dbFileFullName tests:(NSArray <id<YYGDBTesting>> *)tests;

/// YYGDBTestOwning
- (NSString *)dbFileFullName;

/// Test db file
- (BOOL)testDbFile;

/// Error message of failed tests
- (NSString *)messageOfFailedTests;

@end
