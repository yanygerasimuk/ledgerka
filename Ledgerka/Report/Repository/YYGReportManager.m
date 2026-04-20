//
//  YYGReportManager.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YYGLedgerkaDefine.h"
#import "YYGReportManager+YYGReportParameter.h"
#import "YYGReportManager+YYGReportValue.h"
#import "YYGResult.h"

@interface YYGReportManager () {
//    YGSQLite *p_sqlite;
    dispatch_queue_t p_queue;
}

@property (nonatomic, strong) YGSQLite *sqlite;
@end


@implementation YYGReportManager

@synthesize reports = _reports;


#pragma mark - Singleton & init

+ (instancetype)shared
{
    static YYGReportManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YYGReportManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    NSLog(@"-[YYGReportManager init]");
    self = [super init];
    if(self)
    {
        _sqlite = [YGSQLite sharedInstance];
        p_queue = dispatch_queue_create(kReportsQueue, NULL);

        [self buildReportsCache];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(buildReportsCache)
                       name:@"DatabaseRestoredEvent"
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma Entities setter & getter

- (void)setReports:(NSMutableArray <YYGReport *> *)reports
{
    NSLog(@"-[YYGReportManager setReports:]");

    __weak YYGReportManager *weakSelf = self;
    dispatch_async(p_queue, ^{
        YYGReportManager *strongSelf = weakSelf;
        if(strongSelf)
        {
            NSLog(@"\t\treports is setted");
            strongSelf->_reports = reports;
        }
    });
}

- (NSMutableArray <YYGReport *> *)reports
{
    NSLog(@"-[YYGReportManager reports:]");

    __weak YYGReportManager *weakSelf = self;
    dispatch_sync(p_queue, ^{
        YYGReportManager *strongSelf = weakSelf;
        if(strongSelf && !strongSelf->_reports)
        {
            strongSelf->_reports = [NSMutableArray new];
        }
    });
    return _reports;
}


#pragma mark - Inner methods for memory cache process

- (NSArray <YYGReport *> *)reportsFromDb
{

    // TODO: выборка из подчиненных таблиц

    NSLog(@"-[YYGReportManager reportFromDb]");

    NSLog(@"\tisMainThread: %@", [NSThread isMainThread] ? @"YES" : @"NO");

    NSString *sqlQuery = @"SELECT report_id, report_type_id, name, active, created, modified, sort, comment, uuid FROM report ORDER BY active DESC, sort ASC;";

    NSArray *rawList = [self.sqlite selectWithSqlQuery:sqlQuery];

    NSLog(@"\t\trawList: %@", @(rawList.count));

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

- (void)buildReportsCache
{
    NSMutableArray *reports = [[self reportsFromDb] mutableCopy];
    [self sortReportsInArray:reports];
    self.reports = reports;

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];
}

/**
 @warning It will be better if in table entities we have colomn date_unix for sort.
 */
- (void)sortReportsInArray:(NSMutableArray <YYGReport *>*)array {

    NSSortDescriptor *sortOnActiveByDesc = [[NSSortDescriptor alloc] initWithKey:@"active" ascending:NO];
    NSSortDescriptor *sortOnSortByAsc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortOnCreatedByAsc = [[NSSortDescriptor alloc] initWithKey:@"created"  ascending:YES];

    [array sortUsingDescriptors:@[sortOnActiveByDesc, sortOnSortByAsc, sortOnCreatedByAsc]];
}

#pragma mark - Actions on entity(s)

- (NSInteger)idAddReport:(YYGReport *)report {

    NSInteger rowId = -1;

    @try {

        NSArray *reportsArr = [NSArray arrayWithObjects:
                              [NSNumber numberWithInteger:report.type], // entity_type_id
                              report.name ? report.name : [NSNull null], // name
                              [NSNumber numberWithBool:report.isActive], // active
                              [YGTools stringFromDate:report.created], // active_from,
                              report.modified ? [YGTools stringFromDate:report.modified] : [NSNull null], // active_to,
                              [NSNumber numberWithInteger:report.sort], // sort,
                              report.comment ? report.comment : [NSNull null], //comment,
                              [report.uuid UUIDString],
                              nil];

        NSString *insertSQL = @"INSERT INTO report (report_type_id, name, active, created, modified, sort, comment, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";

        // db
        rowId = [self.sqlite addRecord:reportsArr insertSQL:insertSQL];
    }
    @catch (NSException *exception) {
        NSLog(@"Fail in -[YYGReportManager idAddReport]. Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
}

- (NSInteger)addReport:(YYGReport *)report {

    // add entity to db
    NSInteger rowId = [self idAddReport:report];
    YYGReport *newReport = [report copy];
    newReport.rowId = rowId;


    // add entity to memory cache, init if needs
//    if(![self.reports valueForKey:NSStringFromReportType(newReport.type)]){
//        [self.reports setValue:[[NSMutableArray alloc] init] forKey:NSStringFromReportType(newReport.type)];
//    }
//    [[self.reports valueForKey:NSStringFromReportType(newReport.type)] addObject:newReport];

    [self.reports addObject:newReport];
    [self sortReportsInArray:self.reports];
//    [self sortReportsInArray:[self.reports valueForKey:NSStringFromReportType(newReport.type)]];

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];

    return rowId;
}

/**
@warning May be throw exception when return array count > 1?
 */
- (YYGReport *)reportById:(NSInteger)reportId type:(YYGReportType)type
{
    NSLog(@"-[YYGReportManager reportById:type:]");

//    NSArray <YYGReport *> *reportsByType = [self.reports valueForKey:NSStringFromReportType(type)];
    NSArray <YYGReport *> *reportsByType = self.reports;
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", reportId];

    YYGReport *result = [[reportsByType filteredArrayUsingPredicate:idPredicate] firstObject];
    NSLog(@"result: %@", [result description]);
    return result;

//    return [[reportsByType filteredArrayUsingPredicate:idPredicate] firstObject];
}

- (void)updateModifiedReport:(YYGReport *)report
{

}

/**
 Update entity in db and memory cache. Write object as is, without any modifications.

 @warning Is entity needs to update in inner storage?
 @warning It seems entity updated in EditController edit by reference, so...
 */
- (void)updateReport:(YYGReport *)report
{

    // get memory cache
//    NSMutableArray <YYGReport *> *reportsByType = [self.reports valueForKey:NSStringFromReportType(report.type)];

    NSMutableArray <YYGReport *> *reportsByType = self.reports;
    // valueForKey:NSStringFromReportType(report.type)];

    // get update entity
    YYGReport *replaced = [self reportById:report.rowId type:report.type];

    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE report SET report_type_id=%@, name=%@, active=%@, created=%@, modified=%@, sort=%@, comment=%@ WHERE report_id=%@ AND uuid=%@;",
                           [YGTools sqlStringForInt:report.type],
                           [YGTools sqlStringForStringOrNull:report.name],
                           [YGTools sqlStringForBool:report.isActive],
                           [YGTools sqlStringForDateLocalOrNull:report.created],
                           [YGTools sqlStringForDateLocalOrNull:report.modified],
                           [YGTools sqlStringForIntOrDefault:report.sort],
                           [YGTools sqlStringForStringOrNull:report.comment],
                           [YGTools sqlStringForIntOrNull:report.rowId],
                           [YGTools sqlStringForStringNotNull:[report.uuid UUIDString]]
                           ];

    [self.sqlite execSQL:updateSQL];

    // update memory cache
    NSUInteger index = [reportsByType indexOfObject:replaced];
    reportsByType[index] = [report copy];

    // sort memory cache
    [self sortReportsInArray:reportsByType];

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];
}

- (void)deactivateReport:(YYGReport *)report {

    NSDate *now = [NSDate date];

    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE report SET active=0, modified=%@ WHERE report_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)report.rowId];

    [self.sqlite execSQL:updateSQL];

    // update memory cache
    NSMutableArray <YYGReport *> *reportsByType = [self.reports valueForKey:NSStringFromReportType(report.type)];
    YYGReport *updated = [reportsByType objectAtIndex:[reportsByType indexOfObject:report]];
    updated.active = NO;
    updated.modified = now;

    // sort memory cache
    [self sortReportsInArray:reportsByType];

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];
}

- (void)activateReport:(YYGReport *)report {

    NSDate *now = [NSDate date];

    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE report SET active=1, modified=%@ WHERE report_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)report.rowId];

    [self.sqlite execSQL:updateSQL];

    // update memory cache
    NSMutableArray <YYGReport *> *reportsByType = [self.reports valueForKey:NSStringFromReportType(report.type)];
    YYGReport *updated = [reportsByType objectAtIndex:[reportsByType indexOfObject:report]];
    updated.active = YES;
    updated.modified = now;

    [self sortReportsInArray:reportsByType];

    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"ReportManagerCacheUpdateEvent"
                          object:nil];
}

- (YYGResult)removeParametersAndValuesFromReport:(YYGReport *)report
{
    // form sqls
    NSString *deletValuesSql = @"DELETE FROM report_value "
        "WHERE report_parameter_id IN "
        "(SELECT report_parameter_id FROM report_parameter WHERE report_id = %ld);";
    NSString *deleteValues = [NSString stringWithFormat:deletValuesSql, (long)report.rowId];

    NSString *deleteParamsSql = @"DELETE FROM report_parameter WHERE report_id = %ld;";
    NSString *deleteParams = [NSString stringWithFormat:deleteParamsSql, (long)report.rowId];

    // update db
    return [self.sqlite execSyncInTransactionSQLs:@[deleteValues, deleteParams]];
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


#pragma mark - Lists of entitites

- (NSArray <YYGReport *> *)entitiesByType:(YYGReportType)type onlyActive:(BOOL)onlyActive exceptReport:(YYGReport *)exceptReport {
    return [self reportsByType:type onlyActive:onlyActive exceptReport:exceptReport];
}

- (NSArray <YYGReport *> *)entitiesByType:(YYGReportType)type onlyActive:(BOOL)onlyActive {
    return [self reportsByType:type onlyActive:onlyActive exceptReport:nil];
}

- (NSArray <YYGReport *> *)entitiesByType:(YYGReportType)type {
    return [self reportsByType:type onlyActive:NO exceptReport:nil];
}

@end
