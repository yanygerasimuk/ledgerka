//
//  YGAccountChoiceController.m
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGAccountChoiceController.h"
#import "YGEntity.h"
#import "YGEntityManager.h"
#import "YGCategory.h"
#import "YGCategoryManager.h"
#import "YGTools.h"

@interface YGAccountChoiceController () {
    NSArray <YGEntity *> *_accounts;
    NSArray <YGCategory *> *_currencies;
}
@end

@implementation YGAccountChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"ACCOUNT_CHOICE_FORM_TITLE", @"Title of Account choice form.");
    
    // get list of accounts
    YGEntityManager *em = [YGEntityManager sharedInstance];
    if(self.sourceAccount) {
        _accounts = [em entitiesByType:YGEntityTypeAccount onlyActive:YES exceptEntity:self.sourceAccount];
    } else {
        _accounts = [em entitiesByType:YGEntityTypeAccount onlyActive:YES];
    }
    
    // get list of active currencies
    YGCategoryManager *cm = [YGCategoryManager sharedInstance];
    //_currencies = [cm listCategoriesByType:YGCategoryTypeCurrency];
    _currencies = [cm categoriesByType:YGCategoryTypeCurrency onlyActive:YES];
    
    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kAccountCellIdentifier = @"AccountCellIdentifier";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kAccountCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:kAccountCellIdentifier];
    }
    
    YGEntity *account = _accounts[indexPath.row];
    cell.textLabel.text = account.name;
    cell.textLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    
    YGCategory *currency = nil;
    for(YGCategory *c in _currencies) {
        if(c.rowId == account.currencyId) {
            currency = c;
            break;
        }
    }
    
    cell.detailTextLabel.text = [currency shorterName];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.targetAccount = _accounts[indexPath.row];
    
    if(self.customer == YGAccountChoiceCustomerExpense) {
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToExpenseEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerAccountActual) {
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToAccountActualEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerIncome) {
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToIncomeEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerTransferSource) {
        [self performSegueWithIdentifier:@"unwindFromSourceAccountChoiceToTransferEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerTransferTarget) {
        [self performSegueWithIdentifier:@"unwindFromTargetAccountChoiceToTransferEdit" sender:self];
    }
    else
        @throw [NSException exceptionWithName:@"-[YGAccountChoiceController tableView:didSelectRowAtIndexPath:" reason:@"Can not choose customer of account choice" userInfo:nil];
}

@end
