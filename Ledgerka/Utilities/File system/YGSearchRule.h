//
//  YGSearchRule.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGFileSystemObject.h"

@protocol YGConfirmingRule
- (BOOL) isConfirm:(YGFileSystemObject *)object;
@end

@protocol YGDescriptionRule
- (NSString *) descriptionRule;
@end

enum YGSearchRuleType {
    YGSearchRuleTypeDirect,
    YGSearchRuleTypeReverse
};
typedef enum YGSearchRuleType YGSearchRuleType;

@interface YGSearchRule : NSObject

- (instancetype)initWithType:(YGSearchRuleType)type;
- (instancetype)init;

@property (readonly) YGSearchRuleType type;
@property NSString *name;

@end
