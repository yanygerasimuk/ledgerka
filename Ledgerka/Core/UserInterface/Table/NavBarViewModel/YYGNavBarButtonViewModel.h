//
//  YYGNavBarButtonViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.06.2025.
//  Copyright © 2025 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface YYGNavBarButtonViewModel : NSObject

@property (nonatomic, readonly, assign) UIBarButtonSystemItem systemItem;
@property (nonatomic, readonly, copy) void (^action)(void);

- (instancetype)initWithSystemItem:(UIBarButtonSystemItem)systemItem
                            action:(void (^)(void))action;

@end

NS_ASSUME_NONNULL_END
