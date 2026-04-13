//
//  YYGNoDataView.h
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YYGNoDataView : NSObject

- (instancetype)initWithFrame:(CGRect)frame forView:(UIView *)view;
- (void)showMessage:(NSString *)message;
- (void)hide;

@end
