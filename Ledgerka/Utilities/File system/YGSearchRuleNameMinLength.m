//
//  YGSearchRuleNameMinLength.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRuleNameMinLength.h"

@interface YGSearchRuleNameMinLength (){
    NSUInteger _minLength;
}

@end

@implementation YGSearchRuleNameMinLength

- (instancetype)initWithNameMinLength:(NSUInteger)minLength ruleType:(YGSearchRuleType)ruleType{
    self = [super initWithType:ruleType];
    if(self){
        _minLength = minLength;
        self.name = @"Rule for object name to confirm minimum length";
    }
    return self;
}


- (instancetype)initWithNameMinLength:(NSUInteger)minLength{
    return [self initWithNameMinLength:minLength ruleType:YGSearchRuleTypeDirect];
}

- (NSString *) descriptionRule{
    return @"Rule for object name to confirm minimum length";
}

- (BOOL) isConfirm:(YGFileSystemObject *)object{
    
    if([object.name length] >= _minLength)
        return self.type == YGSearchRuleTypeDirect ? YES : NO;
    else
        return self.type == YGSearchRuleTypeReverse ? YES : NO;
}

@end
