//
//  YYGApplication.m
//  Ledgerka
//
//  Created by Ян on 03.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGApplication.h"


@implementation YYGApplication

+ (CGFloat)statusBarHeightWithApplication:(nullable UIApplication *)application
{
    // TODO: > iOS13
    if (application)
    {
        return application.statusBarFrame.size.height;
    }
    else
    {
        return 0.0;
    }
}

+ (CGFloat)navBarHeightWithNavController:(nullable UINavigationController *)navController
{
    // TODO: > iOS13
    if (navController)
    {
        return navController.navigationBar.frame.size.height;
    }
    else
    {
        return 0.0;
    }
}

+ (CGFloat)tabBarHeightWithTabBarController:(nullable UITabBarController *)tabBarController
{
    // TODO: > iOS13
    if (tabBarController)
    {
        return tabBarController.tabBar.frame.size.height;
    }
    else
    {
        return 0.0;
    }
}

@end
