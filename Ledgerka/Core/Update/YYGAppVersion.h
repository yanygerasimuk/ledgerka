//
//  YYGAppVersion.h
//  Ledger
//
//  Created by Ян on 03.07.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGAppVersion : NSObject

@property(assign, nonatomic) NSUInteger major;
@property(assign, nonatomic) NSUInteger minor;
@property(assign, nonatomic) NSUInteger build;

/// Init with version setted in info.plist
- (instancetype)initWithCurruntBundle;

/// Init with version of environment setted in config file
- (instancetype)initWithConfigEnvironmentKeys;

- (NSComparisonResult)compare:(YYGAppVersion *)other;

- (NSString *)toString;

+ (NSArray <YYGAppVersion *> *)updateLog;

@end
