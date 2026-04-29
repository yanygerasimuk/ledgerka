//
//  YYGReportRepository+YYGReportValue.m
//  Ledgerka
//
//  Created by Ян on 04.04.2020.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRepository+YYGReportValue.h"
#import "YYGSQLite.h"


@implementation YYGReportRepository (YYGReportValue)

- (NSArray<YYGReportValue *> *)valuesForParameterId:(NSInteger)parameterId
{
    NSLog(@"-[YYGReportRepository+YYGReportValue valuesForParameterId: %ld]", parameterId);

    NSString *sql = [NSString stringWithFormat:@"SELECT report_value_id, report_value_type_id, report_parameter_id, value_text, value_bool, value_integer, value_float, uuid FROM report_value WHERE report_parameter_id='%ld';", (long)parameterId];
    NSLog(@"sql: %@", sql);

    YYGSQLite *sqlite = [YYGSQLite shared];

    NSArray *rawList = [sqlite selectWithSql:sql];
    NSMutableArray <YYGReportValue *> *result = [NSMutableArray<YYGReportValue *> new];

    for(NSArray *arr in rawList)
    {
        NSInteger rowId = [arr[0] integerValue];
        YYGReportValueType type = [arr[1] integerValue];
        NSInteger parameterId = [arr[2] integerValue];
        NSString *textValue = [arr[3] isEqual:[NSNull null]] ? nil : arr[3];
        BOOL boolValue = [arr[4] boolValue];
        NSInteger integerValue = [arr[5] integerValue];
        double floatValue = [arr[6] doubleValue];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[7]];

        YYGReportValue *value = [[YYGReportValue alloc]
                                 initWithRowId:rowId
                                 type:type
                                 parameterId:parameterId
                                 valueText:textValue
                                 valueBool:boolValue
                                 valueInteger:integerValue
                                 valueFloat:floatValue
                                 uuid:uuid];

        [result addObject:value];
    }
    return [result copy];
}

@end
