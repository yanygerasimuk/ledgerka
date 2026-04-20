//
//  YYGReportManager.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReport.h"
#import "YYGResult.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray <YYGReport *> *reports;

+ (instancetype)shared;

- (instancetype)init;

- (NSInteger)addReport:(YYGReport *)report;
- (YYGReport *)reportById:(NSInteger)reportId type:(YYGReportType)type;
- (void)updateReport:(YYGReport *)report;
- (void)deactivateReport:(YYGReport *)report;
- (void)activateReport:(YYGReport *)report;


- (void)buildReportsCache;

- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type onlyActive:(BOOL)onlyActive exceptReport:(YYGReport *)exceptReport;
- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type onlyActive:(BOOL)onlyActive;
- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type;

/// Remove report
/// - Parameter report: Report
- (YYGResult)removeReport:(YYGReport *)report;
- (YYGResult)removeParametersAndValuesFromReport:(YYGReport *)report;

// TODO: убрать правет методв
- (NSArray <YYGReport *> *)reportsFromDb;

@end

NS_ASSUME_NONNULL_END
