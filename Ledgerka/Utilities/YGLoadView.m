//
//  YGLoadView.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGLoadView.h"
#import "YGTools.h"

@interface YGLoadView() {
    UIView *p_hostView;
    UIActivityIndicatorView *p_activityIndicator;
    UILabel *p_loadMessageLabel;
}
@end

@implementation YGLoadView

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

- (instancetype)initWithHostView:(UIView *)hostView {
    
    // Offset of Y (64) is feature of tableView (not offset of status and nav bars)
    // - 64.0f + 10.0f ранее
    CGRect logFrame = CGRectMake(hostView.frame.size.width/6.0f,
                                 ((hostView.frame.size.height/2.0f)*3.0f)/4.0f - 64.0f + 60.0f,
                                 hostView.frame.size.width*2.0f/3.0f,
                                 hostView.frame.size.height/4.0f + 10.0f);
    
    self = [self initWithFrame:logFrame];
    if(self) {
        p_hostView = hostView;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    // TODO: make design with shadow
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    [p_hostView addSubview:self];
    
    // Activity indicator
    p_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:p_activityIndicator];
    p_activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [p_activityIndicator.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [p_activityIndicator.topAnchor constraintEqualToAnchor:self.topAnchor constant:50.0f].active = YES;
    
    // Message label
    p_loadMessageLabel = [[UILabel alloc] init];
    p_loadMessageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:p_loadMessageLabel];
    p_loadMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [p_loadMessageLabel.topAnchor constraintEqualToAnchor:p_activityIndicator.bottomAnchor constant:20.0f].active = YES;
    [p_loadMessageLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15.0f].active = YES;
    [p_loadMessageLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15.0f].active = YES;
}

- (void)startLoadWithMessage:(NSString *)message {
    self.hidden = false;
    [p_activityIndicator startAnimating];
    p_loadMessageLabel.text = message;
}

- (void)setMessage:(NSString *)message {
    p_loadMessageLabel.text = message;
}

- (void)finishLoad {
    [p_activityIndicator stopAnimating];
    self.hidden = YES;
    [self removeFromSuperview];
}

@end
