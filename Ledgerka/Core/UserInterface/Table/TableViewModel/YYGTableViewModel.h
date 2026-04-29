//
//  YYGTableViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 20.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYGTableItemRegistrable;

NS_ASSUME_NONNULL_BEGIN


@interface YYGTableViewModel : NSObject

@property (nonnull, strong) NSArray<id<YYGTableItemRegistrable>> *items;
@property (nonatomic, assign) BOOL isPullRefreshEnabled;
@property (nonatomic, assign) BOOL isAlwaysScrollable;

/// Уникальные модели для регистрации в таблице
@property (nonnull, readonly, strong) NSArray<id<YYGTableItemRegistrable>> *registrable;

- (instancetype)initWithItems:(NSArray<id<YYGTableItemRegistrable>> *)items;

- (instancetype)initWithItems:(NSArray<id<YYGTableItemRegistrable>> *)items
         isPullRefreshEnabled:(BOOL)isPullRefreshEnabled
           isAlwaysScrollable:(BOOL)isAlwaysScrollable;


@end

NS_ASSUME_NONNULL_END
