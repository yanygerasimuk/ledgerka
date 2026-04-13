//
//  YGEntityViewController.m
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntityViewController.h"
#import "YYGEntityEditController.h"
#import "YYGEntityEditViewModel.h"
#import "YGTools.h"
#import "YGConfig.h"
#import "YYGNoDataView.h"

static NSInteger const kWidthOfMarginIndents = 65;
static NSString *const kEntityCellId = @"EntityCellId";

@interface YGEntityViewController () {
    BOOL p_hideDecimalFraction;
    YYGNoDataView *p_noDataView;
    BOOL p_isEnoughConditionsForNewEntity;
    NSString *p_enoughConditionsWarningMessage;
    UIColor *p_defaultTintColor;
}
@end

@implementation YGEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self injectViewModel];
    
    [self setupUI];
    
    [self bindWithViewModelEvents];
    
    [self reloadDataFromCache];
}

- (void)injectViewModel {
    YGEntityType type = 0;
    switch(self.tabBarController.selectedIndex) {
        case 1:
            type = YGEntityTypeAccount;
            break;
        case 2:
            type = YGEntityTypeDebt;
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGEntityViewController.injectViewModel fails" reason:@"Unknown entity type" userInfo:nil];
    }
    _viewModel = [YYGEntitiesViewModel viewModelWith:type];
}

- (void)setupUI {
    
    // Get configs
    YGConfig *config = [YGTools config];
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    // add button on nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // set title
    self.title = [self.viewModel title];
    
    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Save default tintColor
    p_defaultTintColor = self.navigationController.navigationBar.tintColor;
    
}

- (void)bindWithViewModelEvents {
    
    __weak typeof(self) weakSelf = self;
    [self.viewModel.cacheUpdateEvent subscribeNext:^(NSNumber *isUpdated) {
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf)
            [strongSelf reloadDataFromCache];
    }];
    
    [self.viewModel.decimalFractionHideChangeEvent subscribeNext:^(NSNumber *isHide) {
        __strong typeof(self)strongSelf = weakSelf;
        if(strongSelf)
            strongSelf->p_hideDecimalFraction = [isHide boolValue];
    }];    
}

- (void)reloadDataFromCache {
    
    if(!self.viewModel.entities || [self.viewModel.entities count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.userInteractionEnabled = NO;
        });
        [self showNoDataView];
    } else {
        [self hideNoDataView];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.userInteractionEnabled = YES;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self.tableView reloadData];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Every time check conditions for new debts
    p_isEnoughConditionsForNewEntity = [self.viewModel isEnoughConditionsWithFeedback:^(NSString *message){
        self->p_enoughConditionsWarningMessage = message;
    }];
    
    if(p_isEnoughConditionsForNewEntity)
        self.navigationItem.rightBarButtonItem.tintColor = p_defaultTintColor;
    else
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
}

#pragma mark - Show/hide No operation view

- (void)showNoDataView {
    if(!p_noDataView) {
        p_noDataView = [[YYGNoDataView alloc] initWithFrame:self.tableView.frame forView:self.tableView];
    }
    [p_noDataView showMessage:[self.viewModel noDataMessage]];
}

- (void)hideNoDataView {
    [p_noDataView hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)addButtonPressed {
    
    if(p_isEnoughConditionsForNewEntity) {
        YYGEntityEditController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EntityEditScene"];
        
        editVC.viewModel = [YYGEntityEditViewModel viewModelWith:self.viewModel.type];
        editVC.viewModel.type = self.viewModel.type;
        editVC.viewModel.entity = nil;
        
        [self.navigationController pushViewController:editVC animated:YES];
    } else {
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *warningController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ALERT_CONTROLLER_INFO_TITLE", @"Alert controller information title") message:p_enoughConditionsWarningMessage preferredStyle:UIAlertControllerStyleAlert];
        [warningController addAction:actionOK];
        [self presentViewController:warningController animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGEntityEditController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EntityEditScene"];

    editVC.viewModel = [YYGEntityEditViewModel viewModelWith:self.viewModel.type];
    editVC.viewModel.type = self.viewModel.type;
    editVC.viewModel.entity = [self.viewModel.entities[indexPath.row] copy];
    
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.entities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEntityCellId];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kEntityCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    YGEntity *entity = self.viewModel.entities[indexPath.row];
    
    NSString *currencyName = [self.viewModel currencyNameWithId:entity.currencyId];
    
    // define sum and currency symbol first
    NSDictionary *sumAttributes;
    if([self.viewModel showDebtType]
       && entity.counterpartyId > 0
       && (entity.counterpartyType == YYGCounterpartyTypeDebtor || entity.counterpartyType == YYGCounterpartyTypeCreditor)) {
        if(entity.counterpartyType == YYGCounterpartyTypeCreditor)
            sumAttributes =  @{
                               NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                               NSForegroundColorAttributeName:[YGTools colorRed]
                               };
        else if(entity.counterpartyType == YYGCounterpartyTypeDebtor)
            sumAttributes =  @{
                               NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                               NSForegroundColorAttributeName:[YGTools colorGreen]
                               };
    } else {
        sumAttributes =  @{
                           NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]
                           };
    }
    
    NSString *stringSumAndCurrency = [NSString stringWithFormat:@"%@ %@", [YGTools stringCurrencyFromDouble:entity.sum hideDecimalFraction:p_hideDecimalFraction], currencyName];
    
    NSAttributedString *sumAttributed = [[NSAttributedString alloc] initWithString:stringSumAndCurrency attributes:sumAttributes];
    cell.detailTextLabel.attributedText = sumAttributed;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    // define name of account, trancate if needed
    NSString *stringName = [entity.name copy];
    
    NSInteger widthSum = [YGTools widthForContentString:stringSumAndCurrency];
    NSInteger widthName = [YGTools widthForContentString:stringName];
    
    if(widthName > (self.view.bounds.size.width - widthSum - kWidthOfMarginIndents))
        stringName = [YGTools stringForContentString:stringName holdInWidth:(self.view.bounds.size.width - widthSum - kWidthOfMarginIndents)];
    
    NSDictionary *nameAttributes = nil;
    if(!entity.active) {
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                           NSForegroundColorAttributeName:[UIColor grayColor],
                           };
    } else {
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                           };
    }
    
    NSAttributedString *nameAttributed = [[NSAttributedString alloc] initWithString:stringName attributes:nameAttributes];
    
    cell.textLabel.attributedText = nameAttributed;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}

@end
