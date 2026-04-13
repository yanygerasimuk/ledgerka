//
//  YGSearchRuleDirectoryContainsFileName.h
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"
#import "YGDirectory.h"
#import "YGFile.h"

@interface YGSearchRuleDirectoryContainsFileName : YGSearchRule <YGConfirmingRule, YGDescriptionRule>

- (instancetype)initWithSearchedFileName:(NSString *)name;

- (BOOL) isConfirm:(YGFileSystemObject *)object;
- (NSString *) descriptionRule;

@end

