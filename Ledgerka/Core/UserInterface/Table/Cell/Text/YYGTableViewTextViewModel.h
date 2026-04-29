//
//  YYGTableViewTextViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 30.06.2025.
//  Copyright © 2025 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGTableItemModelable.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGTableViewTextViewModel : NSObject
<
YYGTableItemRegistrable,
YYGTableItemSelectable,
YYGTableItemLocationable
>

@property (nonatomic, nonnull, strong) NSString *title;
@property (nonatomic, nullable, strong) NSString *subtitle;
@property (nonatomic, nullable, strong) NSString *body;
@property (nonatomic, nullable, strong) NSString *caption;

@property (nonatomic, assign) BOOL hasArrow;
@property (nonatomic, assign) BOOL hasDivider;

- (instancetype)initWithTitle:(NSString * _Nonnull)title
                     subtitle:(NSString * _Nullable)subtitle
                         body:(NSString * _Nullable)body
                      caption:(NSString * _Nullable)caption
                     hasArrow:(BOOL)hasArrow
                   hasDivider:(BOOL)hasDivider;

@end

NS_ASSUME_NONNULL_END
