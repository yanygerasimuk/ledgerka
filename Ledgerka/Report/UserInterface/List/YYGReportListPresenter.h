//
//  YYGReportListPresenter.h
//  Ledgerka
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReport.h"
#import "YYGTableViewControllerOutput.h"
#import "YYGReportListPresenterInput.h"

@protocol YYGReportListPresenterOutput;
@protocol YYGTableViewControllerInput;

NS_ASSUME_NONNULL_BEGIN

@interface YYGReportListPresenter : NSObject
<
YYGReportListPresenterInput,
YYGTableViewControllerOutput
>

@property (nonatomic, strong) id<YYGReportListPresenterOutput> output;    /**< Interactor */
@property (nonatomic, weak) id<YYGTableViewControllerInput> view;

@end

NS_ASSUME_NONNULL_END
