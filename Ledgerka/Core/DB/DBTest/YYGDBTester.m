//
//  YYGDBTester.m
//  Ledger
//
//  Created by Ян on 28.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDBTester.h"
@interface YYGDBTester() {
    NSString *p_dbFileFullName;
    NSArray <id<YYGDBTesting>> *p_tests;
}
@end

@implementation YYGDBTester

- (instancetype)initWithDbFile:(NSString *)dbFileFullName tests:(NSArray <id<YYGDBTesting>> *)tests {
    self = [super init];
    if(self) {
        p_dbFileFullName = dbFileFullName;
        p_tests = tests;
        for (id<YYGDBTesting> test in p_tests){
            test.owner = self;
        }
        _failedTests = [NSMutableArray array];
        _passedTests = [NSMutableArray array];
    }
    return self;
}

- (NSString *)dbFileFullName {
    return p_dbFileFullName;
}

- (BOOL)testDbFile {
    
    BOOL testResult = YES;
    
    for (id<YYGDBTesting> test in p_tests){
        if ([test run]){
            [_passedTests addObject:test];
        }
        else {
            [_failedTests addObject:test];
            if(testResult)
                testResult = NO;
            
            if(!test.isContinue)
                break;
        }
    }
    return testResult;
}

- (NSString *)messageOfFailedTests {
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    [message appendString:NSLocalizedString(@"DB_TESTER_FAILED_TEST", @"Failed tests:")];
    for (id<YYGDBTesting> test in _failedTests) {
        [message appendFormat:@"\n• %@", test.message];
    }
    
    return message;
}

@end
