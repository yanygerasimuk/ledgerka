//
//  YGOptionViewController.m
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOptionViewController.h"
#import "YGCategory.h"
#import "YYGCategoriesViewModel.h"
#import "YGCategoryViewController.h"
#import "YYGBackupViewModel.h"
#import "YGDropboxLinkViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "YYGBackupViewController.h"

#import "YGConfig.h"
#import "YGTools.h"

@interface YGOptionViewController () {
    NSString *p_method;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchHideDecimalFraction;
@property (weak, nonatomic) IBOutlet UISwitch *switchPullRefreshAddElement;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOptions;
- (IBAction)switchHideDecimalFractionValueChanged:(UISwitch *)sender;
- (IBAction)switchPullRefreshAddElementValueChanged:(UISwitch *)sender;
@end

@implementation YGOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for(UILabel *label in _labelsOptions) {
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        
        label.attributedText = attributedText;
    }
    
    self.navigationItem.title = NSLocalizedString(@"OPTIONS_VIEW_FORM_TITLE", @"Title of Options form");
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateUI];
    
    // Call delayed method
    if(p_method)
        [self callDelayedMethod];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    YGConfig *config = [YGTools config];
    
    // switch HideDecimalFraction
    self.switchHideDecimalFraction.on = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    // switch PullRefreshToAddElement
    BOOL isPullRefreshToAddElement = NO;
    if([[config valueForKey:@"PullRefreshToAddElement"] isEqualToString:@"Y"])
        isPullRefreshToAddElement = YES;
    self.switchPullRefreshAddElement.on = isPullRefreshToAddElement;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Выбираем целевой вьюКонтроллер вручную
    if (indexPath.section == 1 && indexPath.row == 0) {
        YYGBackupViewController *backupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGBackupViewController"];
        id<YYGBackupViewModelable> viewModel = [YYGBackupViewModel viewModelWith:YYGStorageTypeLocal];
        backupVC.viewModel = viewModel;
        
        [self.navigationController pushViewController:backupVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
            YYGBackupViewController *backupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGBackupViewController"];
            id<YYGBackupViewModelable> viewModel = [YYGBackupViewModel viewModelWith:YYGStorageTypeDropbox];
            backupVC.viewModel = viewModel;

            [self.navigationController pushViewController:backupVC animated:YES];
            
        } else {            
            YGDropboxLinkViewController *dropboxLinkVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YGDropboxLinkViewController"];
            dropboxLinkVC.target = @"BackupDB";
            [self.navigationController pushViewController:dropboxLinkVC animated:YES];
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"%@", [self.tableView indexPathForCell:sender]);
    NSLog(@"%@", [sender description]);
#endif
    
    NSInteger section = [self.tableView indexPathForCell:sender].section;
    
    if(section == 0) { // Dictionaries
        
        NSInteger typeId = [self.tableView indexPathForCell:sender].row + 1;
        YGCategoryType type = (YGCategoryType)typeId;
        
        YGCategoryViewController *vc = segue.destinationViewController;
        
        vc.categoryType = type;
        
        vc.viewModel = [YYGCategoriesViewModel viewModelWith:type];
        
    } // if(section == 0){
}

- (IBAction)switchHideDecimalFractionValueChanged:(UISwitch *)sender {
    YGConfig *config = [YGTools config];
    [config setValue:[NSNumber numberWithBool:sender.isOn] forKey:@"HideDecimalFractionInLists"];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HideDecimalFractionInListsChangedEvent" object:nil];
}

- (IBAction)switchPullRefreshAddElementValueChanged:(UISwitch *)sender {
    YGConfig *config = [YGTools config];
    
    if(sender.isOn)
        [config setValue:@"Y" forKey:@"PullRefreshToAddElement"];
    else
        [config setValue:@"N" forKey:@"PullRefreshToAddElement"];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 2 && indexPath.row == 1)
        height = 0.0f;
    
    return height;
}

/**
 Сообщение реализовано для более аккуратного выведения ячеек: без этого сообщения, если присутствуют скрытые ячейки выводится сокращенный разделитель (как между ячейками одного раздела). Это некрасиво.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0: return 4;
        case 1: return 2;
        case 2: return 1;
        case 3: return 1;
        default: return 0;
    }
}

#pragma mark - DelayedCalling

- (void)setDelayedMethod:(NSString *)method {
    p_method = [method copy];
}

- (void)callDelayedMethod {
    if ([p_method isEqualToString:@"LinkDropbox"])
        [self callLinkDropbox];
    
    p_method = nil;
}

- (void)callLinkDropbox {
    YGDropboxLinkViewController *dropboxLinkVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YGDropboxLinkViewController"];
    dropboxLinkVC.target = @"BackupDB";
    [self.navigationController pushViewController:dropboxLinkVC animated:YES];
}
@end
