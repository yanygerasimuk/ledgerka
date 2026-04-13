//
//  YGFileSystemObject.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, YGFileSystemObjectType) {
    YGFileSystemObjectTypeUnknown = 0,
    YGFileSystemObjectTypeFile = 1 << 0,
    YGFileSystemObjectTypeDirectory = 1 << 1,
    YGFileSystemObjectTypePackage = 1 << 2 
    
};

@interface YGFileSystemObject : NSObject

- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name atPath:(NSString * _Nonnull)path byType:(YGFileSystemObjectType)type;
- (instancetype _Nullable)initWithName:(NSString *_Nonnull)name atPath:(NSString *_Nonnull)path;
- (instancetype _Nullable)initWithPathFull:(NSString * _Nonnull)pathFull;

- (id _Nullable) valueForFileAttributeKey:(NSFileAttributeKey _Nonnull)attributeKey;

- (NSDate * _Nonnull)created;
- (NSDate * _Nonnull)modified;
- (BOOL)isEqual:(YGFileSystemObject * _Nonnull)object;

@property (readonly) NSString * _Nonnull name;
@property (readonly) NSString * _Nonnull path;
@property (readonly) NSString * _Nonnull pathFull;
@property (readonly) YGFileSystemObjectType type;
@property (assign, nonatomic, readonly) NSUInteger size;

@end
