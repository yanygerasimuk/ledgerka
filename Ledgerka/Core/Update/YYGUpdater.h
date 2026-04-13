//
//  YYGUpdater.h
//  Ledger
//
//  Created by Ян on 03.07.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGUpdater : NSObject

- (instancetype)init;
- (void)checkEnvironment;
- (BOOL)isBackupName:(NSString *)name;

@end
