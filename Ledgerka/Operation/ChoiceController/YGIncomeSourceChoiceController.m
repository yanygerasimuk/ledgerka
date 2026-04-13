//
//  YGIncomeSourceChoiceController.m
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGIncomeSourceChoiceController.h"
#import "YGCategoryManager.h"
#import "YGCategory.h"
#import "YGTools.h"

@interface YGIncomeSourceChoiceController () {
    NSArray <YGCategory *> *_incomes;
}
@end

@implementation YGIncomeSourceChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"INCOME_SOURCE_CHOICE_FORM_TITLE", @"Title of Income source choice form.");
    
    YGCategoryManager *cm = [YGCategoryManager sharedInstance];
    
    if(self.sourceIncome) {
        _incomes = [cm categoriesByType:YGCategoryTypeIncome onlyActive:YES exceptCategory:self.sourceIncome];
    } else {
        _incomes = [cm categoriesByType:YGCategoryTypeIncome onlyActive:YES];
    }
    
    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    return [_incomes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *const kIncomeCellIdentifier = @"IncomeCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIncomeCellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIncomeCellIdentifier];
    }
    
    cell.textLabel.text = _incomes[indexPath.row].name;
    cell.textLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.targetIncome = _incomes[indexPath.row];
    
    if(self.customer == YGIncomeSourceChoiceСustomerIncome) {
        [self performSegueWithIdentifier:@"unwindFromIncomeSourceChoiceToIncomeEdit" sender:self];
    } else
        @throw [NSException exceptionWithName:@"-[YGIncomeSourceChoiceController doneButtonPressed" reason:@"Can not choose unwind segue" userInfo:nil];
}

@end
