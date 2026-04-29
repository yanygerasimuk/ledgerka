//
//  YYGNavBarViewModel.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 20.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGNavBarViewModel.h"
#import "YYGNavBarButtonViewModel.h"

@implementation YYGNavBarViewModel

- (instancetype)initWithTitle:(NSString *)title
              backButtonTitle:(NSString *)backButtonTitle
         rightButtonViewModel:(YYGNavBarButtonViewModel *)rightButtonViewModel
{
    self = [super init];
    if (self)
    {
        _title = title;
        _backButtonTitle = backButtonTitle;
        _rightButtonViewModel = rightButtonViewModel;
    }
    return self;
}

@end
