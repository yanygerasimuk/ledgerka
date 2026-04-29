//
//  YYGReportRouter.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 20.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRouter.h"


@interface YYGReportRouter ()

@property (nonatomic, weak) UINavigationController *rootReportNavController;
@property (nonatomic, weak) UIViewController *rootReportViewController;

@end


@implementation YYGReportRouter

- (instancetype)initWithNavController:(UINavigationController *)navController
{
    self = [super init];
    if (self)
    {
        _rootReportNavController = navController;
    }
    return self;
}

- (instancetype)initWithNavController:(UINavigationController *)navController
                    listViewConroller:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        _rootReportNavController = navController;
        _rootReportViewController = viewController;
    }
    return self;
}

@end
