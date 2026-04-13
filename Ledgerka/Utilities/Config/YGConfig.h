//
//  YGConfig.h
//  YGConfig
//
//  Created by Ян on 16/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

/*
 Библиотека предназначена для работы с конфигурационными файлами проектов, приложений, пользовательских настроек для приложений и пользователей.
 
 Термины:
 Проект - папка, содержащая файлы по какой-то теме (проекту), может содержать вложенные папки (подпроекты).
 
 Ограничения:
 1. Библиотека работает только с текущим, вошедшим в систему пользователем.
 */

#import <Foundation/Foundation.h>

@class YGDirectory;
@class YGFile; 

@interface YGConfig : NSObject

/// directory with config file
@property (readonly) YGDirectory *directory;
/// config file, wrap in YGFile object
@property (readonly) YGFile *file;
/// dictionary with keys and values
@property (readonly) NSDictionary *dictionary;

/// base init
- (instancetype)initWithDirectory:(YGDirectory *)directory name:(NSString *)name;

/// init for dir and name
- (instancetype)initWithPath:(NSString *)path name:(NSString *)name;

/// init for config application for user
- (instancetype)initWithApplicationName:(NSString *)name;

/// init for current directory
- (instancetype)init;

- (BOOL) isEmpty;
- (void) setConfigDefaults:(NSDictionary *)dictionary;
- (id) valueForKey:(NSString *)key;
- (void) setValue:(id)value forKey:(NSString *)key;
- (void) removeValueForKey:(NSString *)key;
- (void) writeOnDisk:(NSMutableDictionary *)dict;


@end
