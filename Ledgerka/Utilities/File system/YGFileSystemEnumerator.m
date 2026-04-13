//
//  YGFileSystemEnumerator.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileSystemEnumerator.h"

@interface YGFileSystemEnumerator (){
    YGDirectory *_directory;
    YGSearchPattern *_pattern;
    BOOL _isRecursive;
}

@end

@implementation YGFileSystemEnumerator

- (instancetype)initWithDirectory:(YGDirectory *)directory searchPattern:(YGSearchPattern *) pattern isRecursive:(BOOL)recursive;{
    self = [super init];
    if(self){
        _directory = directory;
        _isRecursive = recursive;
        
        //may be nil
        _pattern = pattern;
    }
    return self;
}

- (instancetype)initWithDirectory:(YGDirectory *)directory searchPattern:(YGSearchPattern *) pattern{
    return [self initWithDirectory:directory searchPattern:pattern isRecursive:NO];
}


- (instancetype)initWithDirectory:(YGDirectory *)directory{
    return [self initWithDirectory:directory searchPattern:nil isRecursive:NO];
}

- (instancetype)init{
    YGDirectory *dir = [[YGDirectory alloc] init];
    return [self initWithDirectory:dir searchPattern:nil isRecursive:NO];
}

- (NSArray <YGFileSystemObject *>*)objects{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:_directory.pathFull];
    NSString *path = nil;
    NSMutableArray <YGFileSystemObject *> *objects = [[NSMutableArray alloc] init];
    
    while(path = [de nextObject]){
#ifdef FUNC_DEBUG
        printf("\nCurrent enum path: %s", [path UTF8String]);
#endif
        if(!_isRecursive)
            [de skipDescendants];
        
        YGFileSystemObject *object = [[YGFileSystemObject alloc] initWithName:path atPath:_directory.pathFull];
        
        //NSLog(@"object: %@", [object description]);
        
        if(_pattern && ![_pattern isObjectConfirm:object]){
#ifdef FUNC_DEBUG
            printf("\nObject is NOT confirm all rules.");
#endif
            continue;
        }
        else{
#ifdef FUNC_DEBUG
            printf("\nObject is confirm all rules.");
#endif
        }

        [objects addObject:object];
    }
    
#ifdef FUNC_DEBUG
    printf("\nEnumerator find %ld object(s)", [objects count]);
#endif
    
    return objects;
}

@end
