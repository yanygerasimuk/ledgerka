//
//  YYGBottomButtonViewModel.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGBottomButtonViewModel.h"


@implementation YYGBottomButtonViewModel

- (instancetype)initWithTitle:(NSString *)title
                        style:(YYGBottomButtonStyle)style
                       action:(void (^)(void))action
{
    self = [super init];
    if (self)
    {
        _title = [title copy];
        _style = style;
        _action = [action copy];
    }
    return self;
}

@end
