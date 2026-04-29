//
//  YYGNavBarButtonViewModel.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.06.2025.
//  Copyright © 2025 Yan Gerasimuk. All rights reserved.
//

#import "YYGNavBarButtonViewModel.h"


@implementation YYGNavBarButtonViewModel

- (instancetype)initWithSystemItem:(UIBarButtonSystemItem)systemItem
                            action:(void (^)(void))action
{
    self = [super init];
    if (self)
    {
        _systemItem = systemItem;
        _action = action;
    }
    return self;
}

@end
