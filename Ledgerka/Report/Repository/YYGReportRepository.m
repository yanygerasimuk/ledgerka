//
//  YYGReportRepository.m
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportRepository.h"
//#import "YYGReportRepositoryOutput.h"
#import "YYGReportRepository+YYGReportParameter.h"
#import "YYGReport.h"
#import "YYGSQLite.h"
#import "YGTools.h"


@implementation YYGReportRepository

- (void)fetchReportsWithSuccessHandler:(void (^)(NSArray<YYGReport *> * _Nonnull))successHandler
                        failureHandler:(void (^)(void))failureHandler
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        @try {
            NSArray <YYGReport *> *result = [self reports];

            [NSThread sleepForTimeInterval:1.0];

            successHandler(result);
//            failureHandler();
        } @catch (NSException *exception) {
            failureHandler();
        }
    });
}


#pragma mark - Private

- (NSArray <YYGReport *>*)reports
{
    NSLog(@"-[repository reports]");
    
    NSString *sql = @"SELECT report_id, report_type_id, name, active, created, modified, sort, comment, uuid FROM report ORDER BY active DESC, sort ASC;";

    YYGSQLite *sqlite = [YYGSQLite shared];
    NSArray *rawList = [sqlite selectWithSql:sql];

    NSMutableArray <YYGReport *> *result = [[NSMutableArray alloc] init];
    for(NSArray *arr in rawList)
    {
        NSInteger rowId = [arr[0] integerValue];
        YYGReportType type = [arr[1] integerValue];
        NSString *name = [arr[2] isEqual:[NSNull null]] ? nil : arr[2];
        BOOL active = [arr[3] boolValue];
        NSDate *created = [YGTools dateFromString:arr[4]];
        NSDate *modified = [YGTools dateFromString:arr[5]];
        NSInteger sort = [arr[6] integerValue];
        NSString *comment = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[8]];

        YYGReport *report = [[YYGReport alloc]
                             initWithRowId:rowId
                             type:type
                             name:name
                             active:active
                             created:created
                             modified:modified
                             sort:sort
                             comment:comment
                             uuid:uuid];

        NSArray<YYGReportParameter *> *params = [self parametersForReportId:rowId];
        report.parameters = [params mutableCopy];

        [result addObject:report];
    }
    return [result copy];
}

@end
