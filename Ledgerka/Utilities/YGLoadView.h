//
//  YGLoadView.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGLoadView : UIView

- (instancetype)initWithHostView:(UIView *)hostView;
- (void)startLoadWithMessage:(NSString *)message;
- (void)setMessage:(NSString *)message;
- (void)finishLoad;

@end
