//
//  YYGReportManager+YYGReportValue.h
//  Ledger
//
//  Created by Ян on 04.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager.h"
#import "YYGReportValue.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportManager (YYGReportValue)

- (NSInteger)addValue:(YYGReportValue *)value;
//- (YYGReportValue *)valueById:(NSInteger)parameterId type:(YYGReportValueType)type;
//- (NSArray <YYGReportValue *> *)valuesByParameterId:(NSInteger)parameterId;
//- (void)updateValue:(YYGReportValue *)value;
//- (void)removeValue:(YYGReportValue *)value forParameterId:(NSInteger *)parameterId;

- (NSArray<YYGReportValue *> *)valuesForReportParameterId:(NSInteger)parameterId;

@end

NS_ASSUME_NONNULL_END
