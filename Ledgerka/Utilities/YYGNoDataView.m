//
//  YYGNoDataView.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGNoDataView.h"
#import "YGTools.h"

@interface YYGNoDataView () {
    CGRect p_frame;
    __weak UIView *p_parentView;
    UIView *p_view;
}
@end

@implementation YYGNoDataView

- (instancetype)initWithFrame:(CGRect)frame forView:(UIView *)view {
    self = [super init];
    if(self){
        p_frame = frame;
        p_parentView = view;
    }
    return self;
}

/**
 Right frame for noDataView = {{0, 0}, {size.width, size.height}} = {{0, 0}, {375, 554}, where size.height == UIScreen.mainScreen.bounds - tabBarHeight.

 @param message Message to show.
 */
- (void)showMessage:(NSString *)message {
    __weak YYGNoDataView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        YYGNoDataView *strongSelf = weakSelf;
        if(strongSelf) {
            if (strongSelf->p_view) {
                [strongSelf->p_view removeFromSuperview];
                strongSelf->p_view = nil;
            }
            
            // Set to one size
            strongSelf->p_frame.origin.y = 0.0f;
            strongSelf->p_frame.size.height = [[UIScreen mainScreen] bounds].size.height - 64.0f - 49.0f;
            
            strongSelf->p_view = [[UIView alloc] initWithFrame:strongSelf->p_frame];
            strongSelf->p_view.backgroundColor = [UIColor colorWithRed:0.9647 green:0.9647 blue:0.9647 alpha:1.0f];
            
            NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:message
                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize] + 2.0f],
                NSForegroundColorAttributeName:[UIColor grayColor]}];
            CGSize size = [attributed size];
            CGFloat y = strongSelf->p_frame.size.height/2 - size.height/2;
            CGFloat x = strongSelf->p_frame.size.width/2 - size.width/2;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, size.width, size.height)];
            label.attributedText = attributed;
            [strongSelf->p_view addSubview:label];
            
            [strongSelf->p_parentView addSubview:strongSelf->p_view];
        }
    });
}

- (void)hide {
    __weak YYGNoDataView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        YYGNoDataView *strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf->p_view removeFromSuperview];
            strongSelf->p_view = nil;
        }
    });
}

@end
