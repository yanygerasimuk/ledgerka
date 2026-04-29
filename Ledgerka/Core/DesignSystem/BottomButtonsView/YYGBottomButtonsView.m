//
//  YYGBottomButtonsView.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 23.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGBottomButtonsView.h"
#import "YYGDesignSystem.h"


@interface YYGBottomButtonsView()

@property (nonatomic, strong) YYGBottomButtonViewModel *firstViewModel;
@property (nonatomic, strong) YYGBottomButton *firstButton;
@property (nonatomic, strong) YYGBottomButtonViewModel *secondViewModel;
@property (nonatomic, strong) YYGBottomButton *secondButton;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UIStackView *stackView;

@end


@implementation YYGBottomButtonsView

- (instancetype)initWithFirstViewModel:(YYGBottomButtonViewModel *)firstViewModel
                       secondViewModel:(YYGBottomButtonViewModel *)secondViewModel
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        [self setupView];
        [self configureWithFirstViewModel:firstViewModel
                          secondViewModel:secondViewModel];
    }

    return self;
}

- (instancetype)init
{
    return [self initWithFirstViewModel:nil secondViewModel:nil];
}


#pragma mark - Private

- (void)setupView
{
    YYGDesignSystem *ds = [YYGDesignSystem shared];
    self.backgroundColor = [UIColor clearColor];

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [ds colorBackgroundIsland];
    [backgroundView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:backgroundView];
    [NSLayoutConstraint activateConstraints:(@[
        [backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]])
    ];
    backgroundView.layer.cornerRadius = 36;
    backgroundView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    backgroundView.layer.borderWidth = 1;
    backgroundView.layer.borderColor = [[ds colorBordersDefault] CGColor];
    backgroundView.clipsToBounds = YES;

    self.stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:self.stackView];
    [NSLayoutConstraint activateConstraints:(@[
        [self.stackView.topAnchor constraintEqualToAnchor:backgroundView.topAnchor constant:20],
        [self.stackView.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor constant:20],
        [self.stackView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-20],
        [self.stackView.bottomAnchor constraintEqualToAnchor:backgroundView.bottomAnchor constant:-15]])
    ];
}

- (void)configureWithViewModel:(YYGBottomButtonViewModel *)viewModel
{
    [self configureWithFirstViewModel:viewModel secondViewModel:nil];
}

- (void)configureWithFirstViewModel:(YYGBottomButtonViewModel *)firstViewModel
                    secondViewModel:(YYGBottomButtonViewModel *)secondViewModel
{
    if (firstViewModel || secondViewModel)
    {
        self.hidden = NO;
    }
    else
    {
        self.hidden = YES;
    }

    for (UIView *subview in [self.stackView.arrangedSubviews copy]) {
        [subview removeFromSuperview];
    }

    if (firstViewModel)
    {
        self.firstViewModel = firstViewModel;
        self.button = [[UIButton alloc] initWithFrame: CGRectZero];
        self.button.layer.cornerRadius = 24;

        [self.button setTitle: firstViewModel.title forState: UIControlStateNormal];

        YYGDesignSystem *ds = [YYGDesignSystem shared];

        [self.button setBackgroundColor: [ds colorTextMint]];

        [self.button setTitleColor: [ds colorTextPrimary] forState:UIControlStateNormal];
        [self.button addTarget:self
                        action:@selector(didTapFirstButton)
              forControlEvents:UIControlEventTouchUpInside];

        [self.stackView addArrangedSubview:self.button];
        [NSLayoutConstraint activateConstraints:@[
            [self.button.heightAnchor constraintEqualToConstant:52.0],
        ]];
    }
    else
    {
        self.firstViewModel = nil;
        self.firstButton = nil;
    }

    if (secondViewModel)
    {
        self.secondViewModel = secondViewModel;
        self.secondButton = [[YYGBottomButton alloc] initWithViewModel:self.secondViewModel];
        [self.secondButton addTarget:self
                             action:@selector(didTapSecondButton)
                   forControlEvents:UIControlEventAllTouchEvents
        ];
        [self.stackView addArrangedSubview:self.secondButton];
    }
    else
    {
        self.secondViewModel = nil;
        self.secondButton = nil;
    }
}

- (void)didTapFirstButton
{
    // Shrink the button to 90% size, then return to normal
    [UIView animateWithDuration:0.1 animations:^{
        self.firstButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.firstButton.transform = CGAffineTransformIdentity;
        }];
        self.firstViewModel.action();
    }];
}

- (void)didTapSecondButton
{
    // Shrink the button to 90% size, then return to normal
    [UIView animateWithDuration:0.1 animations:^{
        self.secondButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.secondButton.transform = CGAffineTransformIdentity;
        }];
        self.secondViewModel.action();
    }];
}

@end
