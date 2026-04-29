//
//  YYGTwoTextsViewModel.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTwoTextsViewModel.h"

@implementation YYGTwoTextsViewModel

- (instancetype)initWithFirstText:(NSAttributedString *)firstText
                       secondText:(NSAttributedString *)secondText
{
    self = [super init];
    if (self)
    {
        _firstText = firstText;
        _secondText = secondText;
    }
    return self;
}

@end
