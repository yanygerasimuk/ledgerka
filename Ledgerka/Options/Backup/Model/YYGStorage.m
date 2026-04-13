//
//  YYGStorage.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorage.h"
#import "YYGStorageDropbox.h"
#import "YYGStorageLocal.h"

@implementation YYGStorage

+ (id<YYGStoraging>)storageWithType:(YYGStorageType) type {
    id<YYGStoraging> storage;
    switch(type){
        case YYGStorageTypeDropbox:
            storage = [[YYGStorageDropbox alloc] init];
            storage.type = YYGStorageTypeDropbox;
            break;
        case YYGStorageTypeLocal:
            storage = [[YYGStorageLocal alloc] init];
            storage.type = YYGStorageTypeLocal;
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGStorage.storageWithType: fails." reason:@"Can not create storage with unknown type." userInfo:nil];
    }
    return storage;
}

/**
 Backup base fileName determine by sort list of all files find by checkBackup function.
 TODO: make validation of fileName.
 
 @return Base fileName of backup.
 */
+ (NSString *)backupFileNameFrom:(NSMutableArray *)fileNames {
    
    // Check
    if ([fileNames count] == 0)
        return nil;
    
    // Result
    NSString *backupFileName = nil;
    
    // Filter input files for timestamp pattern match
    NSArray *filteredNames = [YYGStorage filteredFileNames:fileNames];
    
    // Sort names in DESC order
    NSArray *sortedNames = [filteredNames sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        
        if ([obj1 compare:obj2 options:NSForcedOrderingSearch | NSNumericSearch | NSCaseInsensitiveSearch] == NSOrderedDescending)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    BOOL isPairExists = NO;
    for (NSString *nameI in sortedNames){
        if([nameI hasSuffix:@"sqlite"]){
            NSString *infoFileName = [nameI stringByAppendingString:@".xml"];
            for(NSString *nameJ in sortedNames){
                if (nameI != nameJ && [nameJ hasSuffix:@".xml"]){
                    if ([nameJ isEqualToString:infoFileName]){
                        isPairExists = true;
                        backupFileName = nameI;
                        break;
                    }
                }
            }
        }
        if(isPairExists)
            break;
    }
    
    return backupFileName;
}

+ (NSArray *)filteredFileNames:(NSArray *)fileNames {
    
    // Check
    if ([fileNames count] == 0)
        return nil;
    
    NSMutableArray *resultNames = [NSMutableArray array];
    
    for (NSString *name in fileNames){
        
        // src pattern
        // @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite$"
        NSString *pattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite";
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
        NSMatchingOptions matchingOptions = NSMatchingReportProgress;
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
        
        if(error){
            printf("\nError! Cannot create regex-object. %s", [[error description] UTF8String]);
            continue;
        }
        
        if([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] > 0)
            [resultNames addObject:name];
    }
    return [resultNames copy];
}

+ (YYGDatabaseInfo *)backupInfoFrom:(NSString *)fileName {
    YYGDatabaseInfo *backupInfo = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:fileName]){
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileName];
        if(dict)
            backupInfo = [[YYGDatabaseInfo alloc] initWithDictionary:dict];
    } else {
        NSLog(@"Info file is not exists at path:\n%@", fileName);
    }
    
    return backupInfo;
}

+ (void)removeFileAt:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if(![fileManager removeItemAtPath:fileName error:&error]){
        NSLog(@"Can not remove file: %@", fileName);
        if(error)
            NSLog(@"Error: %@", error);
    }
}

+ (BOOL)isDirectoryExistsAt:(NSString *)path {
    BOOL isExists = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if(isDir)
            isExists = YES;
    }
    return isExists;
}

@end
