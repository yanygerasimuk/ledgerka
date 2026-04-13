//
//  YGSearchRuleHasPrefix.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"

@interface YGSearchRuleHasPrefix : YGSearchRule <YGConfirmingRule, YGDescriptionRule>

- (instancetype)initWithPrefix:(NSString *)prefix ruleType:(YGSearchRuleType)ruleType;
- (instancetype)initWithPrefix:(NSString *)prefix;

- (BOOL) isConfirm:(YGFileSystemObject *)object;
- (NSString *) descriptionRule;

@end
