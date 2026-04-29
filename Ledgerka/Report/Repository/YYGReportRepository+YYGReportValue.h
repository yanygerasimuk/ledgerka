//
//  YYGReportRepository+YYGReportValue.h
//  Ledgerka
//
//  Created by Ян on 04.04.2020.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRepository.h"
#import "YYGReportValue.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGReportRepository (YYGReportValue)

- (NSArray<YYGReportValue *> *)valuesForParameterId:(NSInteger)parameterId;

@end

NS_ASSUME_NONNULL_END
