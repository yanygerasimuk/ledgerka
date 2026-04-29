//
//  YYGReportAssembly.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 17.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportAssembly.h"
#import "YYGDesignSystem.h"
#import "YYGTableViewController.h"
#import "YYGReportListPresenter.h"
#import "YYGReportFlowCoordinator.h"
#import "YYGReportInteractor.h"
#import "YYGReportRepository.h"
#import "YYGReportRouter.h"


@interface YYGReportAssembly ()

@property (nonatomic, weak) YYGReportFlowCoordinator *flowCoordinator;

@end


@implementation YYGReportAssembly

- (UIViewController *)listViewControllerWithNavController:(UINavigationController *)navController
{
//    YYGOptions *options = [YYGOptions new];
//    YYGDesignSystem *designSystem = [[YYGDesignSystem alloc] initWithOptions:options];
    YYGDesignSystem *designSystem = [YYGDesignSystem new];
    YYGTableViewController *viewController = [[YYGTableViewController alloc] initWithDesignSystem:designSystem];
    YYGReportListPresenter *presenter = [YYGReportListPresenter new];

    viewController.output = presenter;
    presenter.view = viewController;

    YYGReportFlowCoordinator *flowCoordinator = [YYGReportFlowCoordinator new];
    flowCoordinator.listPresenter = presenter;
    self.flowCoordinator = flowCoordinator;

    YYGReportInteractor *interactor = [YYGReportInteractor new];
    interactor.output = self.flowCoordinator;
    interactor.listPresenter = presenter;

    // Передалать на weak
    self.flowCoordinator.interactor = interactor;

    presenter.output = interactor;

//    YYGEntityRepository *entityRepository = [YYGEntityRepository new];
//    interactor.entityRepository = entityRepository;
//
//    id<YYGLanguage> language = [[YYGOptions new] language];
//    YYGReportRepository *reportRepository = [[YYGReportRepository alloc] initWithLanguage:language];

    YYGReportRepository *reportRepository = [YYGReportRepository new]; // initWithLanguage:language];
    interactor.reportRepository = reportRepository;
    reportRepository.output = interactor;

    YYGReportRouter *router = [[YYGReportRouter alloc] initWithNavController:navController];
    router.assembly = self;
    flowCoordinator.router = router;

    return viewController;
}

@end
