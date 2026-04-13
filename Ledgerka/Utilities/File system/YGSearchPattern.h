//
//  YGSearchPattern.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGFileSystemObject.h"
#import "YGSearchRule.h"

@interface YGSearchPattern : NSObject

- (instancetype)initWithSearchRules:(NSArray <YGConfirmingRule>*)rules;

- (BOOL)isObjectConfirm:(YGFileSystemObject *)object;

@end
