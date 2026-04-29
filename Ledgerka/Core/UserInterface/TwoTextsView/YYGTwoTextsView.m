//
//  YYGTwoTextsView.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTwoTextsView.h"
#import "YYGDesignSystem.h"


@interface YYGTwoTextsView()

@property(nonatomic, strong) YYGTwoTextsViewModel *viewModel;
@property(nonatomic, strong) UIStackView *stackView;

@end


@implementation YYGTwoTextsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithViewModel:(YYGTwoTextsViewModel *)viewModel
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        [self setupView];
        [self configureWithViewModel:viewModel];
    }
    return self;
}

- (void)setupView
{
    YYGDesignSystem *ds = [YYGDesignSystem shared];
    self.backgroundColor = [ds colorBackgroundOcean];

    self.stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackView.spacing = 10.0;
    self.stackView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:self.stackView];
    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

- (void)configureWithViewModel:(YYGTwoTextsViewModel *)viewModel
{
    self.viewModel = viewModel;

    for (UIView *subview in [self.stackView.arrangedSubviews copy])
    {
        [subview removeFromSuperview];
    }

    if (viewModel.firstText)
    {
        [self addLabelWithText:viewModel.firstText];
    }

    if (viewModel.secondText)
    {
        [self addLabelWithText:viewModel.secondText];
    }

    [self layoutIfNeeded];
}


#pragma mark - Private

- (void)addLabelWithText:(NSAttributedString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.attributedText = text;
    [self.stackView addArrangedSubview:label];
}

@end
