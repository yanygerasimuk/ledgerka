//
//  YYGDBConfig.h
//  Ledger
//
//  Created by Ян on 01/08/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGDBConfig : NSObject

+ (void)setValue:(id)value forKey:(NSString *)key;

+ (id)valueForKey:(NSString *)key;

@end
