//
//  YGSearchRuleNameMinLength.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"

@interface YGSearchRuleNameMinLength : YGSearchRule <YGConfirmingRule, YGDescriptionRule>

- (instancetype)initWithNameMinLength:(NSUInteger)prefix ruleType:(YGSearchRuleType)ruleType;
- (instancetype)initWithNameMinLength:(NSUInteger)prefix;

- (BOOL) isConfirm:(YGFileSystemObject *)object;
- (NSString *) descriptionRule;

@end
