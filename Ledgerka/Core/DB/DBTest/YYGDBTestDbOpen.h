//
//  YYGDBTestDbOpen.h
//  Ledger
//
//  Created by Ян on 28.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGDBTester.h"

@interface YYGDBTestDbOpen : NSObject <YYGDBTesting>

- (instancetype)init;

@property(weak, nonatomic) id<YYGDBTestOwning> owner;

@property(strong, nonatomic) NSString *rule;

@property(strong, nonatomic) NSString *message;

@property(assign, nonatomic) BOOL isContinue;

- (BOOL)run;

@end
