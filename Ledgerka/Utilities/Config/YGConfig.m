//
//  YGConfig.m
//  YGConfig
//
//  Created by Ян on 16/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGConfig.h"
#import "YYGConfigDefine.h"
#import "YGFileSystem.h"

@interface YGConfig ()
- (void) writeOnDisk:(NSMutableDictionary *)dict;
@end

@implementation YGConfig

/// base init
- (instancetype)initWithDirectory:(YGDirectory *)directory name:(NSString *)name{
    
    self = [super init];
    if(self){
        _directory = [directory copy];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *configFileName = [directory.pathFull stringByAppendingPathComponent:name];
        
        if(![fm fileExistsAtPath:configFileName]){
            
            NSString *dateString = [NSString stringWithString:[YGConfig dateNowString]];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dateString, kConfigFileKeyCreated, dateString, kConfigFileKeyModified, nil];
            if (![dict writeToFile:configFileName atomically:YES]){
                @throw [NSException exceptionWithName:@"-[YGConfig initWithDirectory:name:]" reason:@"Error! Can not write empty config file to disk." userInfo:nil];
            }
        }
        
        YGFile *file = [[YGFile alloc] initWithName:name atPath:directory.pathFull];
        _file = file;
        _dictionary = [NSDictionary dictionaryWithContentsOfFile:_file.pathFull];
        
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path name:(NSString *)name {
    YGDirectory *directory = [[YGDirectory alloc] initWithPathFull:path];
    return [self initWithDirectory:directory name:name];
}

/// init for config application for user
- (instancetype)initWithApplicationName:(NSString *)name{
    NSString *homeDir = [NSString stringWithString:NSHomeDirectory()];
    
    YGDirectory *directory = [[YGDirectory alloc] initWithPathFull:homeDir];
    
    NSString *configFileName = [NSString stringWithFormat:@".%@.%@.%@", name, kConfigFileSuffix, kConfigFileExtension];
    
    return [self initWithDirectory:directory name:configFileName];
}

/// init for current directory
- (instancetype)init{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *curDir = [fm currentDirectoryPath];
    
    YGDirectory *directory = [[YGDirectory alloc] initWithPathFull:curDir];
    
    NSString *configFileName = [NSString stringWithFormat:@".%@.%@.%@", directory.name, kConfigFileSuffix, kConfigFileExtension];
    
    return [self initWithDirectory:directory name:configFileName];
}

- (BOOL)isEmpty{
    if([_dictionary count] > 2)
        return NO;
    else
        return YES;
}

- (void)setConfigDefaults:(NSDictionary *)dictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_dictionary];
    [dict setValue:[YGConfig dateNowString] forKey:kConfigFileKeyModified];
    [dict addEntriesFromDictionary:dictionary];
    _dictionary = [dict copy];
    if(![_dictionary writeToFile:_file.pathFull atomically:YES]){
        @throw [NSException exceptionWithName:@"-[YGConfig setConfigDefaults:]" reason:@"Error in write config to disk" userInfo:nil];
    }
}

+ (NSString *)dateNowString{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kConfigFileDateTimeFormat];
    return [formatter stringFromDate:date];
}

- (id)valueForKey:(NSString *)key{
    return [_dictionary objectForKey:key];
}


- (void)setValue:(id)value forKey:(NSString *)key{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_dictionary];
    [dict setValue:value forKey:key];
    
    [self writeOnDisk:dict]; 
}

- (void)removeValueForKey:(NSString *)key{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_dictionary];
    [dict removeObjectForKey:key];
    
    [self writeOnDisk:dict];}

- (void)writeOnDisk:(NSMutableDictionary *)dict{
    
    [dict setValue:[YGConfig dateNowString] forKey:kConfigFileKeyModified];
    _dictionary = [dict copy];

    if(![_dictionary writeToFile:_file.pathFull atomically:YES]){
        @throw [NSException exceptionWithName:@"-[YGConfig writeOnDisk]" reason:@"Error! Can not write config to disk." userInfo:nil];
    }
    
}

#pragma mark - NSCoping

-(id)copyWithZone:(NSZone *)zone{
    YGConfig *newConfig = [[YGConfig alloc] initWithDirectory:_directory name:_file.name];
    
    return newConfig;
}

@end
