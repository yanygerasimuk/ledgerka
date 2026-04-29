//
//  YYGBottomButton.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 21.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import "YYGBottomButton.h"
#import "YYGDesignSystem.h"
#import "YYGBottomButtonViewModel.h"


@interface YYGBottomButton ()

@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) YYGBottomButtonViewModel *viewModel;

@end


@implementation YYGBottomButton

- (instancetype)initWithViewModel:(YYGBottomButtonViewModel *)viewModel
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        _viewModel = viewModel;
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    YYGDesignSystem *ds = [YYGDesignSystem shared];

    // View
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:52]
    ]];

    // Content
    self.content = [UIView new];
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.content setUserInteractionEnabled:NO];
    [self addSubview:self.content];
    [NSLayoutConstraint activateConstraints:@[
        [self.content.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.content.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        [self.content.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.content.leftAnchor constraintEqualToAnchor:self.leftAnchor]
    ]];
    self.content.layer.cornerRadius = 12;
    self.content.layer.borderWidth = 1;

    // Title
    self.title = [[UILabel alloc] initWithFrame:CGRectZero];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.titleLabel setUserInteractionEnabled:NO];
    self.title.font = ds.fontBodyMMed;
    self.title.textColor = ds.colorContentPrimary;
    [self.content addSubview:self.title];
    [NSLayoutConstraint activateConstraints:@[
        [self.title.centerXAnchor constraintEqualToAnchor:self.content.centerXAnchor],
        [self.title.centerYAnchor constraintEqualToAnchor:self.content.centerYAnchor]
    ]];

    // Colors

    switch (self.viewModel.style) {
        case YYGBottomButtonStylePrimary:
            self.content.backgroundColor = ds.colorCallToActionDefault;
            self.title.textColor = ds.colorContentPrimary;
            self.content.layer.borderColor = ds.colorBordersDefault.CGColor;
            break;
        case YYGBottomButtonStyleSecondary:
            self.content.backgroundColor = [UIColor whiteColor];
            self.title.textColor = ds.colorContentPrimary;
            self.content.layer.borderColor = ds.colorBordersDefault.CGColor;
            break;
        case YYGBottomButtonStyleDestructive:
            self.content.backgroundColor = ds.colorSystemWarning;
            self.title.textColor = ds.colorContentPrimary;
            self.content.layer.borderColor = ds.colorBordersDefault.CGColor;
            break;
        default:
            break;
    }
}

@end
