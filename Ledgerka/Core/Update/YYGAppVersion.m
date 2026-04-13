//
//  YYGAppVersion.m
//  Ledger
//
//  Created by Ян on 03.07.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGAppVersion.h"
#import "YGConfig.h"
#import "YYGConfigDefine.h"
#import "YGDirectory.h"
#import "YGTools.h"

@implementation YYGAppVersion

+ (NSArray <YYGAppVersion *> *)updateLog {
    YYGAppVersion *v1_1_13 = [[YYGAppVersion alloc] initWithMajor:1 minor:1 build:13];
    YYGAppVersion *v1_2_6 = [[YYGAppVersion alloc] initWithMajor:1 minor:2 build:6];
    YYGAppVersion *v1_3_3 = [[YYGAppVersion alloc] initWithMajor:1 minor:3 build:3];
    
    return @[v1_1_13, v1_2_6, v1_3_3];
}

/**
 Designed init.

 @param major Major digit version.
 @param minor Minor digit version.
 @param build Build digit version.
 @return Self.
 */
- (instancetype)initWithMajor:(NSInteger)major minor:(NSInteger)minor build:(NSInteger)build {
    self = [super init];
    if(self){
        _major = major;
        _minor = minor;
        _build = build;
    }
    return self;
}

- (instancetype)initWithCurruntBundle {
    
    NSString *major = nil;
    NSString *minor = nil;
    NSString *build = nil;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSArray *version = [shortVersion componentsSeparatedByString:@"."];
    
    switch ([version count]){
        case 2:
            major = version[0];
            minor = version[1];
            break;
        case 1:
            major = version[0];
            break;
        case 0:
        default:
            major = @"0";
            minor = @"0";
    }
    
    build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [self initWithMajor:[major integerValue] minor:[minor integerValue] build:[build integerValue]];
}

- (instancetype)init {
    return [self initWithCurruntBundle];
}

- (instancetype)initWithConfigEnvironmentKeys {
    
    YGDirectory *documents = [[YGDirectory alloc] initWithPathFull: [YGTools documentsDirectoryPath]];
    YGConfig *config = [[YGConfig alloc] initWithDirectory:documents name:@"ledger.config.xml"];
    
    NSString *majorTemp = [config valueForKey:kConfigEnvironmentMajorVersion];
    NSString *minorTemp = [config valueForKey:kConfigEnvironmentMinorVersion];
    NSString *buildTemp = [config valueForKey:kConfigEnvironmentBuildVersion];
    
    NSInteger major = majorTemp ? [majorTemp integerValue] : 0;
    NSInteger minor = minorTemp ? [minorTemp integerValue] : 0;
    NSInteger build = buildTemp ? [buildTemp integerValue] : 0;
    
    return [self initWithMajor:major minor:minor build:build];
}

- (NSComparisonResult)compare:(YYGAppVersion *)other {
    
    if (self.major > other.major)
        return NSOrderedDescending;
    else if (self.major < other.major)
        return NSOrderedAscending;
    else {
        if (self.minor > other.minor)
            return NSOrderedDescending;
        else if (self.minor < other.minor)
            return NSOrderedAscending;
        else {
            if (self.build > other.build)
                return NSOrderedDescending;
            else if (self.build < other.build)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        }
    }
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"%ld.%ld(%ld)", (long)self.major, (long)self.minor, (long)self.build];
}

@end
