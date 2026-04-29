//
//  YYGLoadingViewController.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGLoadingViewController.h"
#import "YYGDesignSystem.h"


@interface YYGLoadingViewController ()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end


@implementation YYGLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setupUI
{
    YYGDesignSystem *ds = [YYGDesignSystem shared];
    self.view.backgroundColor = [ds colorBackgroundOcean];

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blurEffectView = blurEffectView;
    [self.view addSubview:self.blurEffectView];
    [NSLayoutConstraint activateConstraints:@[
        [self.blurEffectView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.blurEffectView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.blurEffectView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.blurEffectView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]
    ]];

    self.activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blurEffectView.contentView addSubview:self.activityIndicator];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.blurEffectView.contentView.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.blurEffectView.contentView.centerYAnchor]
    ]];

}

- (void)show
{
    [self.activityIndicator startAnimating];
}

- (void)hide
{
    [self.activityIndicator stopAnimating];
}

@end
