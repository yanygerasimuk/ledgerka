//
//  YYGReportRouter.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYGReportRouterInput.h"
#import "YYGReportAssembly.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportRouter : NSObject <YYGReportRouterInput>

/// Инициализация Роутера сценариев Отчёты
///
/// @param navController Навигационный контроллер
- (instancetype)initWithNavController:(UINavigationController *)navController;

- (instancetype)initWithNavController:(UINavigationController *)navController
                    listViewConroller:(UIViewController *)viewController;

@property (nonatomic, strong) YYGReportAssembly *assembly;

@end

NS_ASSUME_NONNULL_END
