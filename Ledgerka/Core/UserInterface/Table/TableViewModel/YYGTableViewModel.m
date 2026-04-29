//
//  YYGTableViewModel.m
//  Ledger
//
//  Created by Yan Gerasimuk on 18.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewModel.h"
#import "YYGTableItemModelable.h"
//#import "YYGBottomButtonViewModel.h"


@implementation YYGTableViewModel

- (instancetype)initWithItems:(NSArray<id<YYGTableItemRegistrable>> *)items
         isPullRefreshEnabled:(BOOL)isPullRefreshEnabled
           isAlwaysScrollable:(BOOL)isAlwaysScrollable
{
    self = [super init];
    if (self)
    {
        _items = items;
        _isPullRefreshEnabled = isPullRefreshEnabled;
        _isAlwaysScrollable = isAlwaysScrollable;
    }
    return self;
}

- (instancetype)initWithItems:(NSArray<id<YYGTableItemRegistrable>> *)items
{
    return [self initWithItems:items
          isPullRefreshEnabled:YES
            isAlwaysScrollable:YES
    ];
}

- (NSArray<id<YYGTableItemRegistrable>> *)registrable {
    NSMutableSet *ids = [NSMutableSet<NSString *> new];
    NSMutableArray *result = [NSMutableArray<id<YYGTableItemRegistrable>> new];
    for (id<YYGTableItemRegistrable> item in self.items)
    {
        if (![ids containsObject:item.identifier])
        {
            [result addObject:item];
            [ids addObject:item.identifier];
        }
    }
    return [result copy];
}

@end
