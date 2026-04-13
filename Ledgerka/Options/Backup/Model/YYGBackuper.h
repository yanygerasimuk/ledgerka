//
//  YYGBackuper.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGBackuper : NSObject

/// General file names for db, description and config
@property (strong, nonatomic) NSString *generalFileName;
@property (strong, nonatomic) NSString *generalFilePath;

- (instancetype)init;
- (void)backupWithSuccessHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSString *message))errorHandler;
@end
