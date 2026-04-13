//
//  YYGReportManager+YYGReportParameter.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager.h"
#import "YYGReportParameter.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportManager (YYGReportParameter)

- (NSInteger)addParameter:(YYGReportParameter *)parameter;

- (NSArray<YYGReportParameter *> *)parametersForReportId:(NSInteger)reportId;
//- (YYGReportParameter *)parameterById:(NSInteger)parameterId type:(YYGReportParameterType)type;
//- (NSArray <YYGReportParameter *> *)parametersByReportId:(NSInteger)reportId;
//- (void)updateParameter:(YYGReportParameter *)parameter;
//- (void)removeParameter:(YYGReportParameter *)parameter forReportId:(NSInteger *)reportId;

@end

NS_ASSUME_NONNULL_END
