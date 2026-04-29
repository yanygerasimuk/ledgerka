//
//  YYGReportInteractor.m
//  Ledgerka
//
//  Created by Yan Gerasimuk on 17.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportInteractor.h"
#import "YYGReportInteractorOutput.h"
#import "YYGReportRepositoryInput.h"
#import "YYGReportListPresenterInput.h"

@implementation YYGReportInteractor


#pragma mark - YYGReportListPresenterOutput

- (void)fetchReports
{
    [self.reportRepository fetchReportsWithSuccessHandler:^(NSArray<YYGReport *> * reports) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listPresenter didFetchReports:reports];
        });
    } failureHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listPresenter didFetchReportsWithError];
        });
    }];
}

- (void)didTapAddReport
{
    NSLog(@"yyg -[interactor didTapAddReport]");
}

@end
