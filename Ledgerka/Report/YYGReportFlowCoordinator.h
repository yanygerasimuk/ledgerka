//
//  YYGReportFlowCoordinator.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportInteractorOutput.h"
#import "YYGReportListPresenterOutput.h"

@protocol YYGReportInteractorInput;
@protocol YYGReportListPresenterInput;
@protocol YYGReportRouterInput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportFlowCoordinator : NSObject
<
YYGReportInteractorOutput,
YYGReportListPresenterOutput
>

@property (nonatomic, strong) id<YYGReportInteractorInput> interactor;
@property (nonatomic, strong) id<YYGReportRouterInput> router;

@property (nonatomic, weak) id<YYGReportListPresenterInput> listPresenter;



@end

NS_ASSUME_NONNULL_END
