//
//  YGOperationViewController.m
//  Ledger
//
//  Created by Ян on 12/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationViewController.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGOperationSectionManager.h"
#import "YGEntityManager.h"
#import "YGEntity.h"
#import "YYGOperationSectionHeaderView.h"
#import "YGOperationRow.h"
#import "YGExpenseEditController.h"
#import "YGAccountActualEditController.h"
#import "YGIncomeEditController.h"
#import "YGTransferEditController.h"
#import "YGOperationOneRowCell.h"
#import "YGOperationTwoRowCell.h"
#import "YGTools.h"
#import "YGConfig.h"
#import "YYGNoDataView.h"
#import "YGOperationViewController+Actions.h"
#import "YYGOperationEditViewModel.h"
#import "YYGOperationOneAndHalfRowCell.h"

static NSString *const kOperationOneRowCellId = @"OperationOneRowCellId";
static NSString *const kOperationTwoRowCellId = @"OperationTwoRowCellId";
static NSString *const kOperationOneAndHalfRowCellId = @"OperationOneAndHalfRowCellId";

static NSInteger kTimeIntervalForCheckToday = 10;

@interface YGOperationViewController() {
    NSDate *p_dateDataLoaded;
    
    // Linked to singleton dataSource
    NSMutableArray <YGOperationSection *> *p_sections;
    
    NSArray <YGCategory *> *_currencies;
    NSArray <YGCategory *> *_expenseCategories;
    NSArray <YGCategory *> *_incomeSources;
    NSArray <YGCategory *> *_creditorsOrDebtors;
    NSArray <YGCategory *> *_tags;
    NSArray <YGEntity *> *_accounts;
    NSArray <YGEntity *> *_debts;
    
    YGOperationSectionManager *p_operationSectionManager;
    YGCategoryManager *p_categoryManager;
    YGEntityManager *p_entityManager;
    
//    UIRefreshControl *_refresh;
    
    CGFloat _heightOneRowCell;
    CGFloat _heightTwoRowCell;
    CGFloat _heightOneAndHalfRowCell;
    
    NSTimer *p_timerToday;
    
    BOOL p_isDataSourceChanged;
    
    YYGNoDataView *p_noDataView;
}
@end

@implementation YGOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_operationSectionManager = [YGOperationSectionManager sharedInstance];
    p_categoryManager = [YGCategoryManager sharedInstance];
    p_entityManager = [YGEntityManager sharedInstance];
    
    p_sections = p_operationSectionManager.sections;
    
    p_dateDataLoaded = [NSDate date];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddBarButton)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    self.navigationItem.title = NSLocalizedString(@"OPERATIONS_VIEW_FORM_TITLE", @"Title of Operations form");
    
    // set heights of sections and rows
    _heightOneRowCell = [self heightOneRowCell];
    _heightTwoRowCell = [self heightTwoRowCell];
    _heightOneAndHalfRowCell = [self heightOneAndHalfRowCell];
    
    // cell classes for one and two rows
    [self.tableView registerClass:[YGOperationOneRowCell class] forCellReuseIdentifier:kOperationOneRowCellId];
    [self.tableView registerClass:[YGOperationTwoRowCell class] forCellReuseIdentifier:kOperationTwoRowCellId];
    [self.tableView registerClass:[YYGOperationOneAndHalfRowCell class] forCellReuseIdentifier:kOperationOneAndHalfRowCellId];

    [self addAsObserver];
    
    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // fill table from cache - p_sections;
    p_isDataSourceChanged = NO;
    [self reloadDataFromCache];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    p_timerToday = [NSTimer timerWithTimeInterval:kTimeIntervalForCheckToday
                                           target:self
                                         selector:@selector(checkForToday)
                                         userInfo:nil
                                          repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:p_timerToday forMode:NSDefaultRunLoopMode];
    
    if (p_isDataSourceChanged)
        [self reloadDataSource];
}

/**
 При уходе контроллера дезактивируем таймер.
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [p_timerToday invalidate];
    p_timerToday = nil;
}

/**
 При переходе программы в активное состояние, проверяем совпадает ли установленная при загрузке
 контроллера дата с текущей, если нет получается наступил следующий день и необходимо заново
 сгенерировать секции.
 */
- (void)applicationDidBecomeActiveHandler {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if(![calendar isDateInToday:p_dateDataLoaded])
        [self reloadDataFromCache];
}

/**
 Dealloc. Удаляем все подписки на извещения.
 */
- (void)dealloc {
    // remove self as observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) checkForToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if(![calendar isDateInToday:p_dateDataLoaded])
        [self reloadDataFromCache];
}

- (void) setDataSourceUpdated {
    p_isDataSourceChanged = YES;
}

- (void)reloadDataFromCache {
    
    __weak YGOperationViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf) {
            YGOperationViewController *strongSelf = weakSelf;
            
            // для сравнения с текущей датой при выходе из background/suspend
            strongSelf->p_dateDataLoaded = [NSDate date];
            if(!strongSelf->p_sections || [strongSelf->p_sections count] == 0) {
                strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                strongSelf.tableView.userInteractionEnabled = NO;
                [strongSelf showNoDataView];
            } else {
                [strongSelf hideNoDataView];
                strongSelf.tableView.userInteractionEnabled = YES;
                strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [strongSelf.tableView reloadData];
            }
            strongSelf->p_isDataSourceChanged = NO;
        }
    });
}

//- (void)pullRefreshSwipe:(UIRefreshControl *)refresh {
//
//    [refresh beginRefreshing];
//    [refresh endRefreshing];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self addOperation];
//    });
//}

#pragma mark - Show/hide No operation view

- (void)showNoDataView {
    if(!p_noDataView) {
        p_noDataView = [[YYGNoDataView alloc] initWithFrame:self.tableView.frame forView:self.tableView];
    }
    [p_noDataView showMessage:NSLocalizedString(@"NO_OPERATIONS_LABEL", @"No operations in Operations form.")];
}

- (void)hideNoDataView {
    if(p_noDataView)
        [p_noDataView hide];
}

#pragma mark - Actions

- (void)actionAddBarButton {
    [self showMenuOfOperation];
}

- (void)showMenuOfOperation {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addExpenseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"EXPENSE_ALERT_ITEM_TITLE", @"Expense") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddExpense];
    }];
    [controller addAction:addExpenseAction];
    
    UIAlertAction *addIncomeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"INCOME_ALERT_ITEM_TITLE", @"Income") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddIncome];
    }];
    [controller addAction:addIncomeAction];
    
    UIAlertAction *addTransferAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"TRANSFER_ALERT_ITEM_TITLE", @"Transfer") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddTransfer];
    }];
    [controller addAction:addTransferAction];
    
    UIAlertAction *addAccountActualAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"BALANCE_ALERT_ITEM_TITLE", @"Balance") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddAccountActual];
    }];
    [controller addAction:addAccountActualAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_ALERT_ITEM_TITLE", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    
    if([self.permissionViewModel allowOperationWithDebt]) {
        UIAlertAction *debtsMenuAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"DEBTS_ALERT_ITEM_TITLE", @"Debts...") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addDebtOperation];
        }];
        [controller addAction:debtsMenuAction];
    }
    
    [self presentViewController:controller animated:YES completion:nil];
}

/**
 Список возможных долговых операций:
 1. Установить долг. Фиксируется факт наличия долга мне или моего долга кому-то. Направление определяется в сущности Долг, редактируемой в разделе Долги.
 
 */
- (void)addDebtOperation {
    
    YYGOperationDebtPermissionType permissions = [self.permissionViewModel allowOperationsWithDebt];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if(permissions & YYGOperationDebtPermissionTypeSetDebt) {
        UIAlertAction *setDebtAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_DEBT_OPERATION_MENU_SET_DEBT_TITLE", @"Add debt operation menu - set debt") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionSetDebt];
        }];
        [controller addAction:setDebtAction];
    }
    
    if(permissions & YYGOperationDebtPermissionTypeGiveDebt) {
        UIAlertAction *giveDebtAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_DEBT_OPERATION_MENU_GIVE_DEBT_TITLE", @"Add debt operation menu - give debt") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionGiveDebt];
        }];
        [controller addAction:giveDebtAction];
    }
    
    if(permissions & YYGOperationDebtPermissionTypeRepaymentDebt) {
        UIAlertAction *repaymentDebtAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_DEBT_OPERATION_MENU_REPAYMENT_DEBT_TITLE", @"Add debt operation menu - repayment debt") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionRepaymentDebt];
        }];
        [controller addAction:repaymentDebtAction];
    }
    
    if(permissions & YYGOperationDebtPermissionTypeGetCredit) {
        UIAlertAction *getCreditAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_DEBT_OPERATION_MENU_GET_CREDIT_TITLE", @"Add debt operation menu - get credit") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionGetCredit];
        }];
        [controller addAction:getCreditAction];
    }
    
    if(permissions & YYGOperationDebtPermissionTypeReturnCredit) {
        UIAlertAction *returnCreditAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_DEBT_OPERATION_MENU_RETURN_CREDIT_TITLE", @"Add debt operation menu - return credit") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionReturnCredit];
        }];
        [controller addAction:returnCreditAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_ALERT_ITEM_TITLE", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];

    [self presentViewController:controller animated:YES completion:nil];
}

- (void)updateUI {
    //YGConfig *config = [YGTools config];
    
    /*
    // Hide decimal fraction
    _isHideDecimalFraction = YES;
    if([[config valueForKey:@"HideDecimalFraction"] isEqualToString:@"NO"])
        _isHideDecimalFraction = NO;
     */
    
    // Pull refresh add new element
//    _isPullRefreshToAddElement = NO;
//    if([[config valueForKey:@"PullRefreshToAddElement"] isEqualToString:@"Y"]){
//        _isPullRefreshToAddElement = YES;
//        
//        _refresh = [[UIRefreshControl alloc] init];
//        [_refresh addTarget:self action:@selector(pullRefreshSwipe:) forControlEvents:UIControlEventValueChanged];
//        
//        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"New operation" attributes:nil];
//        _refresh.attributedTitle = attr;
//        
//        self.refreshControl = _refresh;
//    }
//    else{
//        _refresh = nil;
//        self.refreshControl = nil;
//    }
}

#pragma mark - Add concrete action

- (void)actionAddExpense {
    
    if(![p_entityManager isExistActiveEntityOfType:YGEntityTypeAccount]
       || ![p_categoryManager isExistActiveCategoryOfType:YGCategoryTypeExpense]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_EXPENSE_MESSAGE", @"Terms for adding operation Expense") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];

        [self presentViewController:controller animated:YES completion:nil];
    } else {
        YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
        vc.isNewExpense = YES;
        vc.expense = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAddIncome {
    
    if(![p_entityManager isExistActiveEntityOfType:YGEntityTypeAccount]
       || ![p_categoryManager isExistActiveCategoryOfType:YGCategoryTypeIncome]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_INCOME_MESSAGE", @"Terms for adding operation Income") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
        
        vc.isNewIncome = YES;
        vc.income = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAddAccountActual {

    if(![p_entityManager isExistActiveEntityOfType:YGEntityTypeAccount]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_ACCOUNT_ACTUAL_MESSAGE", @"Terms for adding operation Account actual") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
        vc.isNewAccountAcutal = YES;
        vc.accountActual = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAddTransfer {
    
    if([p_entityManager countOfActiveEntitiesOfType:YGEntityTypeAccount] < 2) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_TRANSFER_MESSAGE", @"Terms for adding operation Transfer") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
        vc.isNewTransfer = YES;
        vc.transfer = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];

    if(operationRow.operation.type == YGOperationTypeExpense) {
        YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
        vc.isNewExpense = NO;
        vc.expense = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeAccountActual) {
        YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
        vc.isNewAccountAcutal = NO;
        vc.accountActual = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeIncome) {
        YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
        vc.isNewIncome = NO;
        vc.income = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeTransfer) {
        YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
        vc.isNewTransfer = NO;
        vc.transfer = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeSetDebt) {
        YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
        vc.viewModel = [YYGOperationEditViewModel viewModelWith:operationRow.operation.type];
        vc.viewModel.operation = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeGiveDebt) {
        YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
        vc.viewModel = [YYGOperationEditViewModel viewModelWith:operationRow.operation.type];
        vc.viewModel.operation = [operationRow.operation copy];
        vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeDebtor];

        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeRepaymentDebt) {
        YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
        vc.viewModel = [YYGOperationEditViewModel viewModelWith:operationRow.operation.type];
        vc.viewModel.operation = [operationRow.operation copy];
        vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeDebtor];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeGetCredit) {
        YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
        vc.viewModel = [YYGOperationEditViewModel viewModelWith:operationRow.operation.type];
        vc.viewModel.operation = [operationRow.operation copy];
        vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeCreditor];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeReturnCredit) {
        YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
        vc.viewModel = [YYGOperationEditViewModel viewModelWith:operationRow.operation.type];
        vc.viewModel.operation = [operationRow.operation copy];
        vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeCreditor];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        @throw [NSException exceptionWithName:@"YGOperationViewController tableView:didSelectRowAtIndexPath: fails." reason:@"Unknown operation type for row (cell)." userInfo:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[YYGOperationSectionHeaderView alloc] initWithTitle:p_sections[section].name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [YYGOperationSectionHeaderView height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGOperationType type = p_sections[indexPath.section].operationRows[indexPath.row].operation.type;
    switch(type) {
        case YGOperationTypeIncome:
        case YGOperationTypeExpense:
        case YGOperationTypeAccountActual:
        case YGOperationTypeSetDebt:
            return _heightOneRowCell;
        case YGOperationTypeGiveDebt:
        case YGOperationTypeRepaymentDebt:
        case YGOperationTypeGetCredit:
        case YGOperationTypeReturnCredit:
            return _heightOneAndHalfRowCell;
        case YGOperationTypeTransfer:
            return _heightTwoRowCell;
        default:
            @throw [NSException exceptionWithName:@"YGOperationViewController tableView:heightForRowAtIndexPath: fails." reason:@"Unknown operation type." userInfo:nil];
    }
}

#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [p_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_sections[section].operationRows count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];
    YGOperationType type = operationRow.operation.type;
    
    if(type == YGOperationTypeExpense) {
        YGOperationOneRowCell *cellExpense = (YGOperationOneRowCell *)cell;
        cellExpense.leftText = operationRow.target;
        cellExpense.rightText = operationRow.sourceSum;
    }
    else if(type == YGOperationTypeAccountActual) {
        YGOperationOneRowCell *cellBalance = (YGOperationOneRowCell *)cell;
        cellBalance.leftText = operationRow.target;
        cellBalance.rightText = operationRow.targetSum;
    }
    else if(type == YGOperationTypeIncome) {
        YGOperationOneRowCell *cellIncome = (YGOperationOneRowCell *)cell;
        cellIncome.leftText = operationRow.source;
        cellIncome.rightText = operationRow.targetSum;
    }
    else if(type == YGOperationTypeTransfer) {
        YGOperationTwoRowCell *cellTransfer = (YGOperationTwoRowCell *)cell;
        cellTransfer.firstRowText = operationRow.source;
        cellTransfer.firstRowDetailText = operationRow.sourceSum;
        cellTransfer.secondRowText = operationRow.target;
        cellTransfer.secondRowDetailText = operationRow.targetSum;
    }
    else if(type == YGOperationTypeSetDebt) {
        YGOperationOneRowCell *cellOneRow = (YGOperationOneRowCell *)cell;
        cellOneRow.leftText = operationRow.target;
        cellOneRow.rightText = operationRow.targetSum;
    }
    else if(type == YGOperationTypeGiveDebt || type == YGOperationTypeRepaymentDebt || type == YGOperationTypeGetCredit || type == YGOperationTypeReturnCredit) {
        YYGOperationOneAndHalfRowCell *cellOneAndHalf = (YYGOperationOneAndHalfRowCell *)cell;
        cellOneAndHalf.source = operationRow.source;
        cellOneAndHalf.target = operationRow.target;
        cellOneAndHalf.sum = operationRow.targetSum;
    }
    else {
        @throw [NSException exceptionWithName:@"YGOperationViewController tableView:willDisplayCell:froRowAtIndexPath: fails." reason:@"Unknown operation type for row (cell)." userInfo:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];
    
    YGOperationType type = operationRow.operation.type;
    
    if(type == YGOperationTypeIncome || type == YGOperationTypeExpense || type == YGOperationTypeAccountActual || type == YGOperationTypeSetDebt) {
        YGOperationOneRowCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationOneRowCellId];
        if(!cell)
            cell = [[YGOperationOneRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOperationOneRowCellId];
        cell.type = type;
        return cell;
    }
    else if(type == YGOperationTypeTransfer) {
        YGOperationTwoRowCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationTwoRowCellId];
        if(!cell)
            cell = [[YGOperationTwoRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOperationTwoRowCellId];
        cell.type = type;
        return cell;
    }
    else if(type == YGOperationTypeGiveDebt || type == YGOperationTypeRepaymentDebt || type == YGOperationTypeGetCredit || type == YGOperationTypeReturnCredit) {
        YYGOperationOneAndHalfRowCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationOneAndHalfRowCellId];
        if(!cell)
            cell = [[YYGOperationOneAndHalfRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOperationOneAndHalfRowCellId];
        cell.type = type;
        return cell;
    } else {
        @throw [NSException exceptionWithName:@"YGOperationViewController tableView:cellForRowAtIndexPath: fails" reason:@"Can not create cell for unknown operation type" userInfo:nil];
    }
}

#pragma mark - Helper methods

- (CGFloat)heightOneRowCell {
    static CGFloat heightOneRowCell = 0.f;
    
    if(heightOneRowCell == 0.f) {
        CGFloat width = [YGTools deviceScreenWidth];
        if(width <= 320.f)
            heightOneRowCell = 44.f;
        else if(width > 320 && width <= 375.f)
            heightOneRowCell = 48.f;
        else if(width > 375 && width <= 414.f)
            heightOneRowCell = 52.f;
        else
            heightOneRowCell = 52.f;
    }
    return heightOneRowCell;
}

- (CGFloat)heightOneAndHalfRowCell {
    return 90.0f;
}

- (CGFloat)heightTwoRowCell {
    static CGFloat heightTwoRowCell = 0.f;
    
    if(heightTwoRowCell == 0.f) {
        CGFloat width = [YGTools deviceScreenWidth];
        
        if(width <= 320.f)
            heightTwoRowCell = 80.f;
        else if(width > 320.f && width <= 375.f)
            heightTwoRowCell = 88.f;
        else if(width > 375.f && width <= 414.f)
            heightTwoRowCell = 96.f;
        else
            heightTwoRowCell = 96.f;        
    }
    return heightTwoRowCell;
}

- (void)addAsObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"OperationManagerCacheUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"EntityManagerEntityWithOperationsUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"CategoryManagerCategoryWithObjectsUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"HideDecimalFractionInListsChangedEvent"
                 object:nil];
    
    // Выход из 9i/suspend'a
    [center addObserver:self
               selector:@selector(applicationDidBecomeActiveHandler)
                   name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    
    [center addObserver:self
               selector:@selector(reloadDataSource)
                   name:@"OperationManagerDataSourceUpdateEvent"
                 object:nil];
}

- (void)addPullRefresh {
    UIRefreshControl *pullRefresh = [[UIRefreshControl alloc] init];
    [pullRefresh addTarget:self action:@selector(pullRefreshReloadTable:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = pullRefresh;
}

- (void)reloadDataSource {
    __weak YGOperationViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            YGOperationViewController *strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [strongSelf->p_operationSectionManager makeSections];
                strongSelf->p_sections = strongSelf->p_operationSectionManager.sections;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf reloadDataFromCache];
                });
            });
        } // if (weakSelf)
    });
}

/**
 Pull-Refresh отключен - при жесте пальцем вниз происходит рывок таблицы, когда срабатывает событие.
 Получается таблица как бы вырывается из под пальца - неприятно.
 Поведение это системное, т.е. так себя ведет refreshControl когда просто включено обновление в storyboard.
 
 Reload table data when user pull table down.
 In some case there is sqlite db lock.

 @param sender tableView?
 */
- (void)pullRefreshReloadTable:(id)sender {
    @try {
        self.view.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        
        __weak YGOperationViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                YGOperationViewController *strongSelf = weakSelf;
                
                strongSelf.tableView.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OPERATIONS_VIEW_FORM_PULL_REFRESH_RELOAD_TITLE", @"Title when pull refresh reload table")];
                [strongSelf.tableView.refreshControl beginRefreshing];
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                    [strongSelf->p_operationSectionManager makeSections];
                    strongSelf->p_sections = strongSelf->p_operationSectionManager.sections;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf reloadDataFromCache];
                        [strongSelf.tableView.refreshControl endRefreshing];
                        strongSelf.view.userInteractionEnabled = YES;
                        strongSelf.navigationController.view.userInteractionEnabled = YES;
                    });
                });
            } // if (weakSelf)
        });
    }
    @catch (NSException *ex) {
        NSLog(@"Exception in YGOperationViewController.pullRefreshReloadTable. Description: %@", [ex description]);
    }
}

#pragma mark - ViewModel properties
- (YYGOperationPermissionViewModel *)permissionViewModel {
    if(!_permissionViewModel)
        _permissionViewModel = [[YYGOperationPermissionViewModel alloc] init];
    return _permissionViewModel;
}

@end
