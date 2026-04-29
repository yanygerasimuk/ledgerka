//
//  YYGTableViewTextCell.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 23.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewTextCell.h"
#import "YYGTableViewTextViewModel.h"
#import "YYGDesignSystem.h"


@interface YYGTableViewTextCell ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *captionLabel;

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *dividerView;

@property (nonatomic, strong) YYGDesignSystem *ds;

@end


@implementation YYGTableViewTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _ds = [YYGDesignSystem shared];
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - YYGTableViewCellUpdatable

- (void)updateWithViewModel:(id<YYGTableItemRegistrable>) viewModel
{
    if (![viewModel isMemberOfClass:[YYGTableViewTextViewModel class]])
    {
        return;
    }

    YYGTableViewTextViewModel *model = (YYGTableViewTextViewModel *)viewModel;
    for (UIView *subview in [self.stackView.arrangedSubviews copy]) {
        [subview removeFromSuperview];
    }
    self.titleLabel.text = model.title;
    [self.stackView addArrangedSubview:self.titleLabel];

    if (model.subtitle)
    {
        self.subtitleLabel.text = model.subtitle;
        [self.stackView addArrangedSubview:self.subtitleLabel];
    }

    if (model.body)
    {
        self.bodyLabel.text = model.body;
        [self.stackView addArrangedSubview:self.bodyLabel];
    }

    if (model.caption)
    {
        self.captionLabel.text = model.caption;
        [self.stackView addArrangedSubview:self.captionLabel];
    }

    self.arrowImageView.hidden = !model.hasArrow;

    if (model.hasDivider)
    {
        self.dividerView.hidden = model.location == YYGTableItemLocationOnce || model.location == YYGTableItemLocationLast;
    }
}

#pragma mark - Private

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self setupArrowView];
    [self setupStackView];
    [self setupTextLabels];
    [self setupDividerView];
}

- (void)setupStackView
{
    self.stackView = [[UIStackView alloc] init];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 10;

    [self.contentView addSubview:self.stackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20.0],
        [self.stackView.rightAnchor constraintEqualToAnchor:self.arrowImageView.leftAnchor],
        [self.stackView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:20.0],
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.dividerView.topAnchor constant:-20.0]
    ]];
}

- (void)setupArrowView
{
    UIImage *image = [UIImage imageNamed:@"arrowLeft2Right24Filled"];
    self.arrowImageView = [UIImageView new];
    self.arrowImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.arrowImageView.tintColor = [UIColor lightGrayColor];
    self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.arrowImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.arrowImageView.widthAnchor constraintEqualToConstant:24],
        [self.arrowImageView.heightAnchor constraintEqualToConstant:24],
        [self.arrowImageView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-20],
        [self.arrowImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
    ]];
}

- (void)setupTextLabels
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = self.ds.fontTitleMed;
    self.titleLabel.textColor = self.ds.colorContentPrimary;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subtitleLabel.numberOfLines = 0;
    self.subtitleLabel.font = self.ds.fontBodyMMed;
    self.subtitleLabel.textColor = self.ds.colorContentPrimary;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.font = self.ds.fontBodyMReg;
    self.bodyLabel.textColor = self.ds.colorContentPrimary;
    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.captionLabel.numberOfLines = 0;
    self.captionLabel.font = self.ds.fontCaption;
    self.captionLabel.textColor = self.ds.colorContentSecondary;
    self.captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupDividerView
{
    self.dividerView = [UIView new];
    self.dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dividerView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.dividerView];
    [NSLayoutConstraint activateConstraints:@[
        [self.dividerView.heightAnchor constraintEqualToConstant:1],
        [self.dividerView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:20],
        [self.dividerView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:0],
        [self.dividerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
}

@end
