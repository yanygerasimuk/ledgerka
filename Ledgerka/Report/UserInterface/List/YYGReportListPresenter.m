//
//  YYGReportListPresenter.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListPresenter.h"
#import "YYGReportListPresenterOutput.h"
#import "YYGTableViewControllerInput.h"
#import "YYGTableViewModel.h"
#import "YYGTableViewTextViewModel.h"
#import "YGTools.h"
#import "YYGBottomButtonViewModel.h"
#import "YYGTwoTextsViewModel.h"
#import "YYGDesignSystem+Typography.h"
#import "YYGNavBarViewModel.h"
#import "YYGNavBarButtonViewModel.h"


@interface YYGReportListPresenter ()

@property (nonatomic, strong) NSArray <YYGReport *> *reports;

@end


@implementation YYGReportListPresenter

- (void)viewDidLoad
{
    [self.view showLoading];
    [self.output fetchReports];
}


#pragma mark - YYGReportListPresenterInput

- (void)didFetchReports:(NSArray<YYGReport *> *)reports
{
    [self.view hideLoading];
    self.reports = reports;
    if (reports.count > 0)
    {
        YYGNavBarButtonViewModel *rightButton = [[YYGNavBarButtonViewModel alloc]
                                                 initWithSystemItem:UIBarButtonSystemItemAdd
                                                 action:^{
            [self.output didTapAddReport];
        }];
        YYGNavBarViewModel *navBar = [[YYGNavBarViewModel alloc] initWithTitle:@"Отчёты"
                                                               backButtonTitle:nil
                                                          rightButtonViewModel:rightButton];
        [self.view configureNavBarWithViewModel:navBar];
        [self.view configureTableWithViewModel:[self tableViewModelWithReports:reports]];
    }
    else
    {
        YYGDesignSystem *ds = [YYGDesignSystem shared];

        YYGNavBarButtonViewModel *rightButton = [[YYGNavBarButtonViewModel alloc]
                                                 initWithSystemItem:UIBarButtonSystemItemAdd
                                                 action:^{
            [self.output didTapAddReport];
        }];
        YYGNavBarViewModel *navBar = [[YYGNavBarViewModel alloc] initWithTitle:@"Отчёты"
                                                               backButtonTitle:nil
                                                          rightButtonViewModel:rightButton];
        [self.view configureNavBarWithViewModel:navBar];

        YYGTypography *titleTypography = ds.typographyTitle1;
        YYGTwoTextsViewModel *infoModel = [[YYGTwoTextsViewModel alloc]
        initWithFirstText:[titleTypography attributedWithString:@"Отчётов пока нет"]
        secondText:nil];
        [self.view showInfoWithViewModel:infoModel];

        YYGBottomButtonViewModel *model = [[YYGBottomButtonViewModel alloc]
        initWithTitle:@"Создать отчёт"
        style:YYGBottomButtonStylePrimary
        action:^{
            [self.output didTapAddReport];
        }];
        [self.view configureBottomButtonsWithFirstViewModel:model secondViewModel:nil];
    }
}

- (void)didFetchReportsWithError
{
    YYGDesignSystem *ds = [YYGDesignSystem shared];
    [self.view hideLoading];

    YYGNavBarButtonViewModel *rightButton = [[YYGNavBarButtonViewModel alloc]
                                             initWithSystemItem:UIBarButtonSystemItemRefresh
                                             action:^{
        [self viewDidLoad];
    }];
    YYGNavBarViewModel *navBar = [[YYGNavBarViewModel alloc] initWithTitle:@"Отчёты"
                                                           backButtonTitle:nil
                                                      rightButtonViewModel:rightButton];
    [self.view configureNavBarWithViewModel:navBar];

    YYGTypography *titleTypography = ds.typographyTitle1;
    YYGTypography *textTypography = ds.typographyBody;

    YYGTwoTextsViewModel *infoModel = [[YYGTwoTextsViewModel alloc]
    initWithFirstText:[titleTypography attributedWithString:@"Ошибка"]
    secondText:[textTypography attributedWithString:@"Что-то пошло не так. Попробуйте позже"]];
    [self.view showInfoWithViewModel:infoModel];

    YYGBottomButtonViewModel *model = [[YYGBottomButtonViewModel alloc]
    initWithTitle:@"Обновить"
    style:YYGBottomButtonStylePrimary
    action:^{
        [self viewDidLoad];
    }];
    [self.view configureBottomButtonsWithFirstViewModel:model secondViewModel:nil];
}


#pragma mark - Private

- (YYGTableViewModel *)tableViewModelWithReports:(NSArray<YYGReport *> *)reports
{
    NSMutableArray *items = [NSMutableArray new];

    for (YYGReport *report in reports)
    {
        YYGTableViewTextViewModel *text = [[YYGTableViewTextViewModel alloc]
                                           initWithTitle:report.name
                                           subtitle:nil
                                           body:nil
                                           caption:[YGTools humanViewOfDate:report.modified]
                                           hasArrow:YES
                                           hasDivider:YES
        ];
        [items addObject:text];
    }

    YYGTableViewModel *viewModel = [[YYGTableViewModel alloc] initWithItems:items];
    return viewModel;
}

@end
