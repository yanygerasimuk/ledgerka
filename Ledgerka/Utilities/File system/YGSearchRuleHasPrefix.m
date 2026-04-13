//
//  YGSearchRuleHasPrefix.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRuleHasPrefix.h"

@interface YGSearchRuleHasPrefix (){
    NSString *_prefix;
}

@end

@implementation YGSearchRuleHasPrefix

- (instancetype)initWithPrefix:(NSString *)prefix ruleType:(YGSearchRuleType)ruleType{
    self = [super initWithType:ruleType];
    if(self){
        _prefix = prefix;
        self.name = @"Rule for object name to having prefix";
    }
    return self;
}

- (instancetype)initWithPrefix:(NSString *)prefix{
    return [self initWithPrefix:prefix ruleType:YGSearchRuleTypeDirect];
}

- (NSString *) descriptionRule{
    return @"Rule for object name to having prefix";
}

- (BOOL) isConfirm:(YGFileSystemObject *)object{
 
    if([object.name hasPrefix:_prefix])
        return self.type == YGSearchRuleTypeDirect ? YES : NO;
    else
        return self.type == YGSearchRuleTypeReverse ? YES : NO;
}

@end
