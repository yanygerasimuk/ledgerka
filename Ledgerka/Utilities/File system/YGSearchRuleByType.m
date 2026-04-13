//
//  YGSearchRuleByType.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRuleByType.h"

@interface YGSearchRuleByType (){
    YGFileSystemObjectType _type;
}

@end

@implementation YGSearchRuleByType

- (instancetype)initWithFileSystemObjectType:(YGFileSystemObjectType)type ruleType:(YGSearchRuleType)ruleType{
    self = [super initWithType:ruleType];
    if(self){
        _type = type;
        self.name = @"Rule for object type (file, directory, package, etc.)";
    }
    return self;
}

- (instancetype)initWithFileSystemObjectType:(YGFileSystemObjectType)type{
    return [self initWithFileSystemObjectType:type ruleType:YGSearchRuleTypeDirect];
}

- (NSString *) descriptionRule{
    return @"Rule for object type (file, directory, package, etc.)";
}

- (BOOL) isConfirm:(YGFileSystemObject *)object{
    if(_type == object.type)
        return self.type == YGSearchRuleTypeDirect ? YES : NO;
    else
        return self.type == YGSearchRuleTypeReverse ? YES : NO;
}

@end
