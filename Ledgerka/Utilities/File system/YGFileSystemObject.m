//
//  YGFileSystemObject.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileSystemObject.h"

#import "YYGFileSystemDefine.h"

/**
 YGFileSystemObject represent exists object on file system.
 */

@interface YGFileSystemObject(){
    NSDate *_created;
    NSDate *_modifid;
}
+ (NSString *)nameOfType:(YGFileSystemObjectType)type;
- (YGFileSystemObjectType)typeOfObject;
@end

@implementation YGFileSystemObject

@synthesize size=_size;

- (instancetype)initWithName:(NSString *)name atPath:(NSString *)path byType:(YGFileSystemObjectType)type{
    
    //NSLog(@"name: %@, path: %@, type: %@", name, path, [YGFileSystemObject nameOfType:type]);
    
    self = [super init];
    if(self){
        _name = [name copy];
        _path = [path copy];
        _pathFull = [NSString stringWithFormat:@"%@/%@", _path, _name];
        ;
        
        if(type != YGFileSystemObjectTypeUnknown)
            _type = type;
        else
            _type = [self typeOfObject];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:self.pathFull]){
            printf("\nError! Object is not exist on file system. Object: %s %s", [_name UTF8String], [_pathFull UTF8String]);
            @throw [NSException exceptionWithName:@"-[YGFileSystemObject initWithName:atPath:byType:" reason:@"Object is not exist on file system" userInfo:nil];
        }
        _size = 0;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name atPath:(NSString *)path{
    return [self initWithName:name atPath:path byType:YGFileSystemObjectTypeUnknown];
}

- (instancetype)initWithPathFull:(NSString *)pathFull{
    NSString *name = [NSString stringWithString:[pathFull lastPathComponent]];
    NSString *path = [NSString stringWithString:[pathFull stringByDeletingLastPathComponent]];
    return [self initWithName:name atPath:path byType:YGFileSystemObjectTypeUnknown];
}

- (YGFileSystemObjectType)typeOfObject{
    
    YGFileSystemObjectType resultType = YGFileSystemObjectTypeUnknown;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if([fm fileExistsAtPath:_pathFull isDirectory:&isDirectory]){
        if(isDirectory)
            resultType = YGFileSystemObjectTypeDirectory;
        else
            resultType = YGFileSystemObjectTypeFile;
    }
    else
        @throw [NSException exceptionWithName:@"-[YGFileSystemObject typeOfObject" reason:@"File system object is not exists" userInfo:nil];
    
    return resultType;
}

+ (NSString *)nameOfType:(YGFileSystemObjectType)type{
    if (type == YGFileSystemObjectTypeFile)
        return @"File";
    else if (type == YGFileSystemObjectTypeDirectory)
        return @"Directory";
    else if (type == YGFileSystemObjectTypePackage)
        return @"Package";
    else if (type == YGFileSystemObjectTypeUnknown)
        return @"Unknown";
    else
        @throw [NSException exceptionWithName:@"+[YGFileSystemObject nameOfType]" reason:@"Type of FileSystemObject is not difined" userInfo:nil];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Instanse class: %@, name: %@, path: %@, pathFull: %@, type: %@", [self class], _name, _path, _pathFull, [YGFileSystemObject nameOfType:_type]];
}

- (id _Nullable) valueForFileAttributeKey:(NSFileAttributeKey)attributeKey{
    
    id result;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    printf("\nattr for name: %s at path: %s, full path: %s", [self.name UTF8String], [self.path UTF8String], [self.pathFull UTF8String]);
    
    @try{
        NSDictionary *attributes = [fm attributesOfItemAtPath:_pathFull error:&error];
        
        if(error){
            printf("\nError! Can not read file attributes");
        }
        
        //NSLog(@"attribute class: %@", [attributes[attributeKey] class]);
        
        id  attribute = attributes[attributeKey];
        
        if((attributeKey == NSFileCreationDate)
           || (attributeKey == NSFileModificationDate)){
            
            NSString *dateStringFromFileSystem = [NSString stringWithFormat:@"%@", attribute];
            
            NSDateFormatter *formatterFromFileSystem = [[NSDateFormatter alloc] init];
            [formatterFromFileSystem setDateFormat:kFileDateTimeFormatFromFSAttributes]; //2017-04-27 21:16:49 +0000
            NSDate *dateOnFileSystem = [formatterFromFileSystem dateFromString:dateStringFromFileSystem];
            
            result = dateOnFileSystem;
            
        }
    }
    @catch(NSException *ex){
        printf("\nError! Exception in -[YGFileSystemObject valueForFileAttributeKey. Exception: %s.", [[ex description] UTF8String]);
    }
    @finally{
        return result;
    }
}

- (NSDate *)created{
    return [self valueForFileAttributeKey:NSFileCreationDate];
}

- (NSDate *)modified{
    return [self valueForFileAttributeKey:NSFileModificationDate];
}

- (BOOL)isEqual:(YGFileSystemObject *)object{
    
    if(_type != object.type)
        return NO;
    else if([_name compare:object.name] != NSOrderedSame)
        return NO;
    else if([_path compare:object.path] != NSOrderedSame)
        return NO;
    
    return YES;
}

-(NSUInteger)size {
    
    if(_size == 0){
        
        if (_type == YGFileSystemObjectTypeFile){
            
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *error = nil;
            NSDictionary *attr = [fm attributesOfItemAtPath:_pathFull error:&error];
            
            NSNumber *number = [NSNumber numberWithUnsignedInteger:0];
            number = [attr valueForKey:@"NSFileSize"];
            _size = [number unsignedIntegerValue];
            
            if(error)
                NSLog(@"Fail to get size of file: %@. Error: %@", _pathFull, error);
        }
        else{
            @throw [NSException exceptionWithName:@"-[YGFileSysterObject size]" reason:[NSString stringWithFormat:@"Fail to get fso size for type: %ld", (long)_type] userInfo:nil];
        }
    }
    
    return _size;
}

@end
