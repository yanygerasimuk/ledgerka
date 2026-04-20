//
//  YYGTableViewController.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 17.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTableViewController.h"

@interface YYGTableViewController ()

@property (nonatomic, strong) YYGDesignSystem *designSystem;

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
    // Do any additional setup after loading the view.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
