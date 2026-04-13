//
//  YGSearchRule.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRule.h"

@implementation YGSearchRule

- (instancetype)initWithType:(YGSearchRuleType)type{
    self = [super init];
    if(self){
        _type = type;
    }
    return self;
}

- (instancetype)init{
    return [self initWithType:YGSearchRuleTypeDirect];
}

@end
