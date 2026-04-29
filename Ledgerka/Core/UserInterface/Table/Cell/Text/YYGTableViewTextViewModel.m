//
//  YYGTableViewTextViewModel.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 23.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewTextViewModel.h"
#import "YYGTableViewTextCell.h"

@implementation YYGTableViewTextViewModel

@synthesize cellClass = _cellClass;
@synthesize identifier = _identifier;
@synthesize canSelected = _canSelected;
@synthesize location = _location;

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         body:(NSString *)body
                      caption:(NSString *)caption
                     hasArrow:(BOOL)hasArrow
                   hasDivider:(BOOL)hasDivider
{
    self = [super init];
    if (self)
    {
        _cellClass = [YYGTableViewTextCell class];
        _identifier = NSStringFromClass([YYGTableViewTextCell class]);
        _title = title;
        _subtitle = subtitle;
        _body = body;
        _caption = caption;
        _hasArrow = hasArrow;
        _hasDivider = hasDivider;
    }
    return self;
}

#pragma mark - YYGTableItemSelectable

- (BOOL)canSelected
{
    return YES;
}

@end
