//
//  YYGReportInteractor.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportInteractorInput.h"
#import "YYGReportListPresenterOutput.h"
#import "YYGReportRepositoryOutput.h"


@protocol YYGReportInteractorOutput;
@protocol YYGReportRepositoryInput;


NS_ASSUME_NONNULL_BEGIN

@interface YYGReportInteractor : NSObject
<
YYGReportInteractorInput,
YYGReportRepositoryOutput,
YYGReportListPresenterOutput
>

@property (nonatomic, strong) id<YYGReportInteractorOutput> output; /**< FlowCoordinator */
@property (nonatomic, strong) id<YYGReportRepositoryInput> reportRepository; /**< Репозиторий отчётов */

@end

NS_ASSUME_NONNULL_END
