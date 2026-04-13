//
//  YGFileSystemEnumerator.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGFileSystemObject.h"
#import "YGDirectory.h"
#import "YGSearchPattern.h"

@interface YGFileSystemEnumerator : NSObject

- (instancetype)initWithDirectory:(YGDirectory *)directory searchPattern:(YGSearchPattern *)pattern isRecursive:(BOOL)recursive;
- (instancetype)initWithDirectory:(YGDirectory *)directory searchPattern:(YGSearchPattern *)pattern;
- (instancetype)initWithDirectory:(YGDirectory *)directory;
- (instancetype)init;

- (NSArray <YGFileSystemObject *>*)objects;

@end
