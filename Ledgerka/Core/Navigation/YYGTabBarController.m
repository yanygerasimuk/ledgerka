//
//  YYGTabBarController.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 16.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGTabBarController.h"
#import "YGOperationViewController.h"
#import "YGEntityViewController.h"
//#import "YYGReportListViewController.h"
#import "YGOptionViewController.h"
#import "YYGReportAssembly.h"
//#import "YYGNavigationController.h"
//#import "YYGOptions.h"


typedef NS_ENUM(NSInteger, YYGTabTag)
{
    YYGTabTagOperation        = 0,
    YYGTabTagReport            = 1,
    YYGTabTagAccount        = 2,
    YYGTabTagDebt            = 3,
    YYGTabTagOption            = 4
};


@interface YYGTabBarController ()

@property (nonatomic, strong) YYGDesignSystem *ds;

@end


// TODO: добавить локализацию строк
@implementation YYGTabBarController

- (instancetype)initWithDesignSystem:(YYGDesignSystem *)ds
{
    self = [super init];
    if (self)
    {
        _ds = ds;
    }
    return self;
}

- (void)setupAppearance
{
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
        appearance.backgroundColor = [self.ds colorBackgroundIsland];

        // Selected state
//        appearance.stackedLayoutAppearance.selected.iconColor = [UIColor blueColor];
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
//
//        appearance.stackedLayoutAppearance.normal.iconColor = [UIColor grayColor];
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};

        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAppearance];

    UINavigationController *operationNC = [self navControllerForOperation];
    UINavigationController *reportNC = [self navControllerForReport];
    UINavigationController *accountNC = [self navControllerForAccount];
    UINavigationController *debtNC = [self navControllerForDebt];
    UINavigationController *optionNC = [self navControllerForOption];

    self.viewControllers = @[operationNC, reportNC, accountNC, debtNC, optionNC];
//    self.viewControllers = @[operationNC, accountNC, debtNC, optionNC];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UINavigationController *)navControllerForOperation
{
    UINavigationController *operationNC = [self navControllerWithIdentifier:@"OperationsNavController"];
    UIViewController *operationVC = [self viewControllerWithIdentifier:@"YGOperationViewController"];

    operationNC.viewControllers = @[operationVC];
    UIImage *accountImage = [UIImage imageNamed:@"tabBarIconOperations"];
    operationNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Операции"
                                                         image:accountImage
                                                           tag:YYGTabTagOperation];

    return operationNC;
}

/// Навигационный контроллер для Отчётов
- (UINavigationController *)navControllerForReport
{
    UINavigationController *navController = [UINavigationController new];
    YYGReportAssembly *assembly = [YYGReportAssembly new];
    UIViewController *vc = [assembly listViewControllerWithNavController:navController];

    navController.viewControllers = @[vc];
    UIImage *reportImage = [UIImage imageNamed:@"tabBarIconReports"];
    navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Отчёты"
                                                             image:reportImage
                                                               tag:YYGTabTagReport];
    return navController;
    return nil;
}

- (UINavigationController *)navControllerForAccount
{
    UINavigationController *accountNC = [self navControllerWithIdentifier:@"AccountsNavController"];
    UIViewController *vc = [self viewControllerWithIdentifier:@"YGEntityViewController"];
    YGEntityViewController *accountVC = (YGEntityViewController *)vc;

//    accountVC.type = YGEntityTypeAccount;
    accountNC.viewControllers = @[accountVC];
    UIImage *accountImage = [UIImage imageNamed:@"tabBarIconAccounts"];
    accountNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Счета"
                                                         image:accountImage
                                                           tag:YYGTabTagAccount];

    return accountNC;
}

- (UINavigationController *)navControllerForDebt
{
    UINavigationController *debtNC = [self navControllerWithIdentifier:@"DebtsNavController"];
    UIViewController *vc = [self viewControllerWithIdentifier:@"YGEntityViewController"];
    YGEntityViewController *debtVC = (YGEntityViewController *)vc;

//    debtVC.type = YGEntityTypeDebt;
    debtNC.viewControllers = @[debtVC];
    UIImage *accountImage = [UIImage imageNamed:@"tabBarIconDebts"];
    debtNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Долги"
                                                      image:accountImage
                                                        tag:YYGTabTagDebt];

    return debtNC;
}

- (UINavigationController *)navControllerForOption
{
    UINavigationController *optionNC = [self navControllerWithIdentifier:@"OptionNavController"];
    UIViewController *optionVC = [self viewControllerWithIdentifier:@"YGOptionViewController"];

    optionNC.viewControllers = @[optionVC];
    UIImage *accountImage = [UIImage imageNamed:@"tabBarIconOptions"];
    optionNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Настройки"
                                                        image:accountImage
                                                          tag:YYGTabTagOption];

    return optionNC;
}


#pragma mark - Private

- (UINavigationController *)navControllerWithIdentifier:(NSString *)identifier
{
    UIViewController *vc = [self viewControllerWithIdentifier:identifier];

    if (!vc)
    {
        return nil;
    }

    UINavigationController *nc = (UINavigationController *)vc;
    if (!nc)
    {
        return nil;
    }
    else
    {
        return nc;
    }
}

- (UIViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:identifier];

    if (!vc)
    {
        return nil;
    }
    else
    {
        return vc;
    }
}


#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
