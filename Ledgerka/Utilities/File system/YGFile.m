//
//  YGFile.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFile.h"

@implementation YGFile

/**
 
 */
- (instancetype)initWithName:(NSString *)name atPath:(NSString *)path{
    self = [super initWithName:name atPath:path byType:YGFileSystemObjectTypeFile];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YGFile *f = [[YGFile alloc] initWithName:[self name] atPath:[self path]];
    return f;
}

@end
