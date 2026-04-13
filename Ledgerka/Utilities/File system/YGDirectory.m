//
//  YGDirectory.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGDirectory.h"
#import "YGFileSystemEnumerator.h"


@interface YGDirectory (){
    NSArray <YGFileSystemObject *>*_contents;
}
@end

@implementation YGDirectory

- (instancetype)initWithName:(NSString *)name atPath:(NSString *)path{
    self = [super initWithName:name atPath:path byType:YGFileSystemObjectTypeDirectory];
    return self;
}

- (instancetype)initWithPathFull:(NSString *)pathFull{
    self = [super initWithPathFull:pathFull];
    return self;
}

- (instancetype)initWithFileSystemObject:(YGFileSystemObject *)object{
    self = [super initWithName:object.name atPath:object.path byType:object.type];
    return self;
}

- (instancetype)init{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [fm currentDirectoryPath];
    self = [self initWithPathFull:path];
    return self;
}

/**
 Lazy func
 */
- (NSArray <YGFileSystemObject *>*)contents{
    
    NSArray <YGFileSystemObject *>*resultArray = nil;
    
    YGFileSystemEnumerator *en = [[YGFileSystemEnumerator alloc] initWithDirectory:self];
    
    resultArray = [en objects];
    
    return resultArray;
}

- (id)copyWithZone:(NSZone *)zone {
    YGDirectory *d = [[YGDirectory alloc] initWithPathFull:self.pathFull];
    return d;
}

@end
