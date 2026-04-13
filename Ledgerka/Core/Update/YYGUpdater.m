//
//  YYGUpdater.m
//  Ledger
//
//  Created by Ян on 03.07.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGUpdater.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import "YGTools.h"
#import "YGDirectory.h"
#import "YYGAppVersion.h"
#import "YYGConfigDefine.h"
#import "YYGDBLog.h"

@implementation YYGUpdater

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)checkEnvironment {
    YYGAppVersion *currentAppVersion = [[YYGAppVersion alloc] initWithCurruntBundle];
    YYGAppVersion *environmentVersion = [[YYGAppVersion alloc] initWithConfigEnvironmentKeys];
    BOOL isAnyUpdateExec = NO;
    
    // Check if appVersion is higher then environmentVersion
    if ([currentAppVersion compare:environmentVersion] == NSOrderedDescending) {
        
        // Check each update version
        for(YYGAppVersion *version in [YYGAppVersion updateLog]) {
            
            environmentVersion = [[YYGAppVersion alloc] initWithConfigEnvironmentKeys];
            
            NSComparisonResult result = [version compare:environmentVersion];
            if(result == NSOrderedDescending) {
                
                isAnyUpdateExec = YES;
                
                SEL updateEnvironment = [[self class] updateEnvironment:version];
                
                // Check if app have update for new version
                if ([self respondsToSelector:updateEnvironment]) {
                    NSString *message;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if([[self performSelector:updateEnvironment] boolValue]) {
                        [self setEnvironmentVersionAsAppVersion:version];
                        message = [NSString stringWithFormat:@"Success update to version %@", [version toString]];
                    } else
                        message = [NSString stringWithFormat:@"Fail update to version: %@", [version toString]];
#pragma clang diagnostic pop
                    // Log event
                    [YYGDBLog logEvent:message];
                    NSLog(@"%@", message);
                }
            }
        } // for
        
        // If no updates execute, but current version still higher, reset it
        if (!isAnyUpdateExec &&
            [currentAppVersion compare:environmentVersion] == NSOrderedDescending)
            [self setEnvironmentVersionAsAppVersion:currentAppVersion];
    }
}

+ (SEL)updateEnvironment:(YYGAppVersion *)appVersion {
    
    NSString *version = [NSString stringWithFormat:@"Major%ldMinor%ldBuild%ld", (long)appVersion.major, (long)appVersion.minor, (long)appVersion.build];
    
    return NSSelectorFromString([NSString stringWithFormat:@"updateToVersion%@", version]);
}

#pragma mark - Help funcs

- (BOOL)isBackupName:(NSString *)name {
    
    // src pattern
    // @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite"
    NSString *pattern = kBackupFileNamePattern;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSMatchingOptions matchingOptions = NSMatchingReportProgress;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    
    if(error){
        printf("\nError! Cannot create regex-object. %s", [[error description] UTF8String]);
        return NO;
    }
    
    if([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] > 0)
        return YES;
    else
        return NO;
}

- (void)setEnvironmentVersionAsAppVersion:(YYGAppVersion *)appVersion {
    
    YGDirectory *documents = [[YGDirectory alloc] initWithPathFull: [YGTools documentsDirectoryPath]];
    YGConfig *config = [[YGConfig alloc] initWithDirectory:documents name:@"ledger.config.xml"];
    
    [config setValue:@(appVersion.major) forKey:kConfigEnvironmentMajorVersion];
    [config setValue:@(appVersion.minor) forKey:kConfigEnvironmentMinorVersion];
    [config setValue:@(appVersion.build) forKey:kConfigEnvironmentBuildVersion];
}

@end
