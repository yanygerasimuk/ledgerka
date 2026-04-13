//
//  YYGDatabaseInfo.h
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGDatabaseInfo : NSObject

@property (strong, nonatomic) NSString *lastOperation;
@property (strong, nonatomic) NSString *databaseSize;
@property (strong, nonatomic) NSString *backupDate;

- (instancetype)initWithWorkDb;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
