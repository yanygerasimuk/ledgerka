//
//  YYGEntitySelectController.m
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitySelectController.h"
#import "YGEntity.h"
#import "YGTools.h"

@interface YYGEntitySelectController () {
    NSArray <YGEntity *> *p_entities;
    BOOL p_isCacheActual;
}
@end

@implementation YYGEntitySelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Config UI
    self.title = [self.viewModel title];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Subscribe to cache event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(markCacheAsUnactual)
                   name:@"EntityManagerCacheUpdateEvent"
                 object:nil];
    
    // Load entities
    [self loadEntities];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!p_isCacheActual)
        [self loadEntities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Load categories

- (void) markCacheAsUnactual {
    p_isCacheActual = NO;
}

- (void)loadEntities {
    p_entities = [self.viewModel getEntities];
    [self.tableView reloadData];
    p_isCacheActual = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_entities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const kEntityCellId = @"EntityCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kEntityCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:kEntityCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Text
    NSString *text = [self.viewModel textOf:p_entities[indexPath.row]];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    cell.textLabel.attributedText = attributed;
    
    // Detail text
    if([self.viewModel showDetailText]) {
        NSString *detailText = [self.viewModel detailTextOf:p_entities[indexPath.row]];
        NSDictionary *detailAttributes;
        
        if(self.viewModel.supposedCurrency) {
            if(p_entities[indexPath.row].currencyId == self.viewModel.supposedCurrency.rowId) {
                detailAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
                
            } else {
                detailAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:[UIColor redColor]};
            }
        } else {
            detailAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
        }
        
        NSAttributedString *detailAttributed = [[NSAttributedString alloc] initWithString:detailText attributes:detailAttributes];
        cell.detailTextLabel.attributedText = detailAttributed;
    }
    return cell;
}

#pragma mark - didSelectRowAtIndexPath and goto YGAccountEditController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.viewModel.target = p_entities[indexPath.row];
    [self performSegueWithIdentifier:[self.viewModel unwindSegueName] sender:self];
}

@end
