//
//  YYGReportRepository+YYGReportParameter.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRepository.h"
#import "YYGReportParameter.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGReportRepository (YYGReportParameter)

- (NSArray<YYGReportParameter *> *)parametersForReportId:(NSInteger)reportId;

@end

NS_ASSUME_NONNULL_END
