//
//  YYGReportManager+YYGReportParameter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager+YYGReportParameter.h"
#import "YYGReportManager+YYGReportValue.h"
#import "YGTools.h"
#import "YGSQLite.h"


@interface YYGReportManager ()

@property (nonatomic, strong) YGSQLite *sqlite;

@end


@implementation YYGReportManager (YYGReportParameter)

- (NSInteger)addParameter:(YYGReportParameter *)parameter
{
    NSInteger rowId = -1;
    @try
    {
        
        NSArray *parameterArr = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInteger:parameter.type],
                                 [NSNumber numberWithInteger:parameter.reportRowId],
                                 [parameter.uuid UUIDString],
                                 nil];

        NSString *insertSQL = @"INSERT INTO report_parameter (report_parameter_type_id, report_id, uuid) VALUES (?, ?, ?);";
        
        rowId = [self.sqlite addRecord:parameterArr insertSQL:insertSQL];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Fail in -[YYGReportManager addParameter]. Exception: %@", [exception description]);
    }
    @finally
    {
        return rowId;
    }
}

- (YYGResult)removeReport:(YYGReport *)report
{
    // form sqls
    NSString *sql = @"DELETE FROM report_value "
        "WHERE report_parameter_id IN "
        "(SELECT report_parameter_id FROM report_parameter WHERE report_id = %ld);";
    NSString *deleteValues = [NSString stringWithFormat:sql, (long)report.rowId];

    sql = @"DELETE FROM report_parameter WHERE report_id = %ld;";
    NSString *deleteParams = [NSString stringWithFormat:sql, (long)report.rowId];

    sql = @"DELETE FROM report WHERE report_id = %ld;";
    NSString *deleteReport = [NSString stringWithFormat:sql, (long)report.rowId];

    // update db
    YYGResult result = [self.sqlite execSyncInTransactionSQLs:@[deleteValues, deleteParams, deleteReport]];

    // update memory cache
    NSLog(@"reports count BEFORE: %ld", (long)[self.reports count]);
    [self.reports removeObject:report];
    NSLog(@"reports count AFTER: %ld", (long)[self.reports count]);

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];
    return result;
}

- (NSArray<YYGReportParameter *> *)parametersForReportId:(NSInteger)reportId
{
    NSLog(@"-[YYGReportManager parametersForReportId]");

    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT report_parameter_id, report_parameter_type_id, report_id, uuid FROM report_parameter WHERE report_id='%ld' ORDER BY report_parameter_id;", (long)reportId];

    NSArray *rawList = [self.sqlite selectWithSqlQuery:sqlQuery];

    NSLog(@"\t\trawList: %@", @(rawList.count));

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

        NSArray<YYGReportValue *> *values = [self valuesForReportParameterId:parameter.rowId];
        parameter.values = [values mutableCopy];

        [result addObject:parameter];
    }
    return [result copy];
}


//- (YYGReportParameter *)parameterById:(NSInteger)parameterId type:(YYGReportParameterType)type
//{
//    return nil;
//}
//
//- (NSArray <YYGReportParameter *> *)parametersByReportId:(NSInteger)reportId
//{
//    return nil;
//}
//
//- (void)updateParameter:(YYGReportParameter *)parameter
//{
//
//}
//
//- (void)removeParameter:(YYGReportParameter *)parameter forReportId:(NSInteger *)reportId
//{
//
//}

@end
