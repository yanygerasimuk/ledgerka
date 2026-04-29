//
//  YYGReportRepository+YYGReportParameter.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRepository+YYGReportParameter.h"
#import "YYGReportRepository+YYGReportValue.h"
#import "YYGSQLite.h"


@implementation YYGReportRepository (YYGReportParameter)

- (NSArray<YYGReportParameter *> *)parametersForReportId:(NSInteger)reportId
{
    NSLog(@"-[YYGReportManager parametersForReportId: %ld]", reportId);

    NSString *sql = [NSString stringWithFormat:@"SELECT report_parameter_id, report_parameter_type_id, report_id, uuid FROM report_parameter WHERE report_id='%ld' ORDER BY report_parameter_id;", (long)reportId];

    YYGSQLite *sqlite = [YYGSQLite shared];

    NSArray *rawList = [sqlite selectWithSql:sql];
    NSMutableArray <YYGReportParameter *> *result = [NSMutableArray <YYGReportParameter *> new];

    for(NSArray *arr in rawList)
    {
        NSInteger rowId = [arr[0] integerValue];
        YYGReportParameterType type = [arr[1] integerValue];
        NSInteger reportId = [arr[2] integerValue];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[3]];

        YYGReportParameter *parameter = [[YYGReportParameter alloc]
                                         initWithRowId:rowId
                                         type:type
                                         reportRowId:reportId
                                         uuid: uuid];

        NSArray<YYGReportValue *> *values = [self valuesForParameterId:parameter.rowId];
        parameter.values = [values mutableCopy];

        [result addObject:parameter];
    }
    return [result copy];
}

@end
