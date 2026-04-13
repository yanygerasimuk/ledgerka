//
//  YGSearchPattern.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchPattern.h"

@interface YGSearchPattern (){
    NSArray <YGConfirmingRule>*_rules;
}

@end

@implementation YGSearchPattern

- (instancetype)initWithSearchRules:(NSArray <YGConfirmingRule>*)rules{
    self = [super init];
    if(self){
        _rules = rules;
    }
    return self;
}

- (BOOL)isObjectConfirm:(YGFileSystemObject *)object{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    for (id<YGConfirmingRule, YGDescriptionRule> rule in _rules){
#ifdef FUNC_DEBUG
        printf("\n...%s", [[rule descriptionRule] UTF8String]);
#endif
        
        if(![rule isConfirm:object])
            return NO;
    }
    return YES;
}

@end
