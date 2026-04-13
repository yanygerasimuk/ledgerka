//
//  YYGReportManager+YYGReportValue.m
//  Ledger
//
//  Created by Ян on 04.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager+YYGReportValue.h"
#import "YGSQLite.h"


@interface YYGReportManager ()

@property (nonatomic, strong) YGSQLite *sqlite;

@end


@implementation YYGReportManager (YYGReportValue)

- (NSInteger)addValue:(YYGReportValue *)value
{
    NSInteger rowId = -1;
    @try
    {
        NSArray *valueArr = [NSArray arrayWithObjects:
                             [NSNumber numberWithInteger:value.type], // entity_type_id
                             [NSNumber numberWithInteger:value.parameterId], // entity_type_id
                             value.valueText ? value.valueText : [NSNull null],
                             [NSNumber numberWithBool:value.valueBool],
                             [NSNumber numberWithInteger:value.valueInteger],
                             [NSNumber numberWithDouble:value.valueFloat],
                             [value.uuid UUIDString],
                             nil];

        NSString *insertSQL = @"INSERT INTO report_value "
        "(report_value_type_id, report_parameter_id, "
        "value_text, value_bool, value_integer, value_float, uuid) VALUES "
        "(?, ?, ?, ?, ?, ?, ?);";

        rowId = [self.sqlite addRecord:valueArr insertSQL:insertSQL];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Fail in -[YYGReportManager addValue]. Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
}

- (NSArray<YYGReportValue *> *)valuesForReportParameterId:(NSInteger)parameterId
{
    NSLog(@"[YYGReportManager+YYGReportValue valuesForReportParameterId:]");

    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT report_value_id, report_value_type_id, report_parameter_id, value_text, value_bool, value_integer, value_float, uuid FROM report_value WHERE report_parameter_id='%ld';", (long)parameterId];
    NSLog(@"sql: %@", sqlQuery);



//    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT type, value FROM config WHERE key='%@' LIMIT 1;", key];

    NSArray *rawList = [self.sqlite selectWithSqlQuery:sqlQuery];

    NSLog(@"\t\trawList: %@", @(rawList.count));

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
    NSLog(@"\tresult.count: %@", @(result.count));
    NSLog(@"");
    return [result copy];
}

@end
