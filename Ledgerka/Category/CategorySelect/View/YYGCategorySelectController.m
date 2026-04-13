//
//  YYGCategorySelectController.m
//  Ledger
//
//  Created by Ян on 02.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategorySelectController.h"
#import "YGCategory.h"
#import "YGTools.h"

@interface YYGCategorySelectController () {
    NSArray <YGCategory *> *p_categories;
}
@end

@implementation YYGCategorySelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Config tableView
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Load data
    [self loadCategories];

    self.title = [self.viewModel title];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadCategories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load categories

- (void)loadCategories {
    if(self.viewModel.source)
        p_categories = [self.viewModel activeCategoriesExcept:self.viewModel.source];
    else
        p_categories = [self.viewModel activeCategories];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const kCurrencyCellId = @"CategoryCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCurrencyCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:kCurrencyCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Text
    NSString *text = [self.viewModel textOf:p_categories[indexPath.row]];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    cell.textLabel.attributedText = attributed;
    
    // Detail text
    if([self.viewModel showDetailText]) {
        NSString *detailText = [self.viewModel detailTextOf:p_categories[indexPath.row]];
        NSDictionary *detailAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
        
        //NSAttributedString *symbolAttributed = [[NSAttributedString alloc] initWithString:[self.currencies[indexPath.row] shorterName] attributes:symbolAttributes];
        NSAttributedString *detailAttributed = [[NSAttributedString alloc] initWithString:detailText attributes:detailAttributes];
        cell.detailTextLabel.attributedText = detailAttributed;
    }
    
    return cell;
}

#pragma mark - didSelectRowAtIndexPath and goto YGAccountEditController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.viewModel.target = p_categories[indexPath.row];
    [self performSegueWithIdentifier:[self.viewModel unwindSegueName] sender:self];
}

@end
