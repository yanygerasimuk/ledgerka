//
//  YYGBottomButtonViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGBottomButton.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGBottomButtonViewModel : NSObject

@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, assign) YYGBottomButtonStyle style;
@property (nonatomic, readonly, copy) void (^action)(void);

- (instancetype)initWithTitle:(NSString *)title
                        style:(YYGBottomButtonStyle)style
                       action:(void (^)(void))action;

@end

NS_ASSUME_NONNULL_END

