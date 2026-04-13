//
//  YGSearchRuleNameIsRegex.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"

@interface YGSearchRuleNameIsRegex : YGSearchRule <YGConfirmingRule, YGDescriptionRule>

- (instancetype)initWithPattern:(NSString *)pattern ruleType:(YGSearchRuleType)ruleType;
- (instancetype)initWithPattern:(NSString *)pattern;

- (BOOL) isConfirm:(YGFileSystemObject *)object;
- (NSString *) descriptionRule;

@end
