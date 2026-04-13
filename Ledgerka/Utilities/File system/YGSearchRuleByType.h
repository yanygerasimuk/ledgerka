//
//  YGSearchRuleByType.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"

@interface YGSearchRuleByType : YGSearchRule <YGConfirmingRule, YGDescriptionRule>

- (instancetype)initWithFileSystemObjectType:(YGFileSystemObjectType)type ruleType:(YGSearchRuleType)ruleType;

- (instancetype)initWithFileSystemObjectType:(YGFileSystemObjectType)type;

- (BOOL) isConfirm:(YGFileSystemObject *)object;
- (NSString *) descriptionRule;

@end
