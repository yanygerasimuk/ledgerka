//
//  YYGApplication.h
//  Ledgerka
//
//  Created by Ян on 03.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface YYGApplication : NSObject

/// Высота статусБара для приложения
/// @param application Приложение
+ (CGFloat)statusBarHeightWithApplication:(nullable UIApplication *)application;

/// Высота навБара для навКонтроллера
/// @param navController НавКонтролле
+ (CGFloat)navBarHeightWithNavController:(nullable UINavigationController *)navController;

/// Высота табБара для табБарКонтроллера
/// @param tabBarController ТабБарКонтроллер
+ (CGFloat)tabBarHeightWithTabBarController:(nullable UITabBarController *)tabBarController;

@end

NS_ASSUME_NONNULL_END
