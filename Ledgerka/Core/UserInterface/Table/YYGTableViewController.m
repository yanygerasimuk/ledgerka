//
//  YYGTableViewController.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 17.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewController.h"
#import "YYGTableViewControllerOutput.h"
#import "YYGTableItemModelable.h"
#import "YYGLoadingViewController.h"
#import "YYGBottomButtonsView.h"
#import "YYGTwoTextsView.h"
#import "YYGNavBarViewModel.h"
#import "YYGNavBarButtonViewModel.h"


@interface YYGTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) YYGDesignSystem *designSystem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *pullRefresh;
@property (nonatomic, weak) YYGLoadingViewController *loadingVC;
@property (nonatomic, strong) YYGTwoTextsView *infoView;
@property (nonatomic, strong) YYGBottomButtonsView *bottomButtonsView;
@property (nonatomic, strong) YYGNavBarButtonViewModel *rightNavBarButtonViewModel;
@property (nonatomic, strong) YYGTableViewModel *tableViewModel;

@end


@implementation YYGTableViewController

- (instancetype)initWithDesignSystem:(YYGDesignSystem *)designSystem
{
    self = [super init];
    if (self)
    {
        _designSystem = designSystem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self.output viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(updateTextStyles:)
      name:UIContentSizeCategoryDidChangeNotification
      object:nil];
}

- (void)updateTextStyles:(NSNotification *)notification
{
    // не работает
//    [self.view layoutSubviews];
//    [self.view layoutIfNeeded];
}

#pragma mark - YYGTableViewControllerInput

- (void)configureNavBarWithViewModel:(YYGNavBarViewModel *)viewModel
{
    self.title = viewModel.title;

    if (viewModel.backButtonTitle) {
        self.navigationItem.backButtonTitle = viewModel.backButtonTitle;
    }
    else
    {
        self.navigationItem.backButtonTitle = nil;
    }

    if (viewModel.rightButtonViewModel) {
        self.rightNavBarButtonViewModel = viewModel.rightButtonViewModel;
        UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:viewModel.rightButtonViewModel.systemItem
                                   target:self
                                   action:@selector(didTapNavBarRightButton)];
        self.navigationItem.rightBarButtonItem = button;
    }
    else
    {
        self.rightNavBarButtonViewModel = nil;
    }
}

- (void)didTapNavBarRightButton
{
    self.rightNavBarButtonViewModel.action();
}

- (void)configureTableWithViewModel:(YYGTableViewModel *)tableViewModel
{
    self.tableViewModel = tableViewModel;
    self.tableView.hidden = tableViewModel == nil;

    if (tableViewModel.isPullRefreshEnabled)
    {
        [self addPullRefresh];
    }
    else
    {
        self.tableView.refreshControl = nil;
    }

    if (tableViewModel.isAlwaysScrollable)
    {
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.showsHorizontalScrollIndicator = YES;
        self.tableView.alwaysBounceVertical = YES;
    }
    else
    {
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.alwaysBounceVertical = NO;
    }

    // Register cells
    for (id<YYGTableItemRegistrable> item in tableViewModel.registrable)
    {
        [self.tableView registerClass:item.cellClass
               forCellReuseIdentifier:item.identifier];
    }
    [self.tableView reloadData];
}

- (void)configureBottomButtonsWithFirstViewModel:(YYGBottomButtonViewModel *)firstViewModel
                                 secondViewModel:(YYGBottomButtonViewModel *)secondViewModel
{
    self.bottomButtonsView.hidden = NO;
    [self.bottomButtonsView configureWithFirstViewModel:firstViewModel
                                        secondViewModel:secondViewModel];
    [self.view bringSubviewToFront:self.bottomButtonsView];
}

- (void)showLoading
{
    YYGLoadingViewController *vc = [YYGLoadingViewController new];
    self.loadingVC = vc;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [self.loadingVC show];
}

- (void)hideLoading
{
    [self.loadingVC hide];
    [self.loadingVC.view removeFromSuperview];
    [self.loadingVC willMoveToParentViewController:nil];
    [self.loadingVC removeFromParentViewController];
    [self.loadingVC didMoveToParentViewController:nil];
    self.loadingVC = nil;
}

- (void)showInfoWithViewModel:(YYGTwoTextsViewModel *)viewModel
{
    self.infoView.hidden = NO;
    [self.infoView configureWithViewModel:viewModel];
}

- (void)hideInfoView
{
    self.infoView.hidden = YES;
}

- (void)addPullRefresh
{
    self.pullRefresh = [[UIRefreshControl alloc] init];
    [self.pullRefresh addTarget:self action:@selector(pullRefreshTable) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.pullRefresh;
}

- (void)pullRefreshTable
{
    NSLog(@"yyg table.pullRefreshTable()");
//    if (self.pullRefresh.isRefreshing)
//        return;
//    [self.pullRefresh endRefreshing];
    [self.output didPullRefresh];
}

- (void)hidePullRefresh
{
    NSLog(@"-[table hidePullRefresh]");
    [self.tableView.refreshControl endRefreshing];
}


#pragma mark - Private

- (void)setupUI
{
    [self createBottomButtonsView];
    [self createTableView];
    [self createInfoView];
}

- (void)createBottomButtonsView
{
    self.bottomButtonsView = [[YYGBottomButtonsView alloc] initWithFirstViewModel:nil secondViewModel:nil];
    self.bottomButtonsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomButtonsView.hidden = YES;
    [self.view addSubview:self.bottomButtonsView];
    [NSLayoutConstraint activateConstraints:@[
        [self.bottomButtonsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomButtonsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomButtonsView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints: @[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomButtonsView.topAnchor]]
    ];
}

- (void)createInfoView
{
    self.infoView = [[YYGTwoTextsView alloc] initWithFrame:CGRectZero];
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoView.hidden = YES;
    [self.view addSubview:self.infoView];
    [NSLayoutConstraint activateConstraints:@[
        [self.infoView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.infoView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.infoView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.infoView.bottomAnchor constraintEqualToAnchor:self.bottomButtonsView.topAnchor constant:36]
    ]];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 64;
//}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    id<YYGTableItemRegistrable> item = self.tableViewModel.items[indexPath.row];
    if (!item)
    {
        return [UITableViewCell new];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.identifier forIndexPath:indexPath];

    if ([item conformsToProtocol:@protocol(YYGTableItemLocationable)])
    {
        id<YYGTableItemLocationable> locationable = (id<YYGTableItemLocationable>)item;
        if (self.tableViewModel.items.count == 1)
            locationable.location = YYGTableItemLocationOnce;
        else if (indexPath.row == 0)
            locationable.location = YYGTableItemLocationFirst;
        else if (indexPath.row == self.tableViewModel.items.count - 1)
            locationable.location = YYGTableItemLocationLast;
        else
            locationable.location = YYGTableItemLocationMedium;
    }

    if ([cell conformsToProtocol:@protocol(YYGTableItemUpdatable)])
    {
        id<YYGTableItemUpdatable> updatable = (id<YYGTableItemUpdatable>)cell;
        [updatable updateWithViewModel:item];
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewModel.items.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    id item = self.tableViewModel.items[indexPath.row];
    id<YYGTableItemActionable> actionable = (id<YYGTableItemActionable>)item;
    if ([actionable conformsToProtocol:@protocol(YYGTableItemActionable)] &&
        actionable.action != nil)
    {
        [actionable action];
        return;
    }

    id<YYGTableItemSelectable> selectable = (id<YYGTableItemSelectable>)item;
    if ([selectable conformsToProtocol:@protocol(YYGTableItemSelectable)] &&
        selectable.canSelected)
    {
        [self.output didSelectRowAtIndexPath:indexPath];
    }
}

@end
