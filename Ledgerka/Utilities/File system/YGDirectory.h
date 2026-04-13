//
//  YGDirectory.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileSystemObject.h"

@interface YGDirectory : YGFileSystemObject

- (instancetype)initWithName:(NSString *)name atPath:(NSString *)path;
- (instancetype)initWithPathFull:(NSString *)pathFull;
- (instancetype)initWithFileSystemObject:(YGFileSystemObject *)object;
- (instancetype)init;

- (NSArray <YGFileSystemObject *>*)contents;

@end
