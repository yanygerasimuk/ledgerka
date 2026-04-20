//
//  YYGReportRepositoryInput.h
//  Ledgerka
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

//#import "YYGReport.h"
//#import "YGEntity.h"
//#import "YYGAccountBalanceModel.h"
//#import "YYGAccountBalanceReport.h"
//#import "YYGResult.h"


NS_ASSUME_NONNULL_BEGIN


/// Входящие сообщения репозитория отчётов
@protocol YYGReportRepositoryInput

///// Отчёты
//- (NSArray <YYGReport *> *)reports;
//
///// Добавить отчёт "Остатки по счетам"
///// @param date Дата, если отсутствует, то текущая
///// @param accounts Счета, если отсутствует, то все счета
//- (void)addAccountBalancesWithDate:(nullable NSDate *)date
//                          accounts:(nullable NSArray <YGEntity *> *)accounts;
//
///// Обновить отчёт "Остатки по счетам"
///// @param report Счёт
//- (void)updateAccountBalancesWithReport:(nonnull YYGReport *)report;
//
//- (YYGAccountBalanceReport *)enrichToAccountBalanceReport: (YYGReport *)report;
//
//- (YYGReport *)addAccountBalanceWithModel:(YYGAccountBalanceModel *)model;
//
//- (YYGReport *)editAccountBalanceReport:(YYGReport *)report
//                              withModel:(YYGAccountBalanceModel *)model;
//
//- (void)reloadReports;
//
//- (YYGResult)removeReport:(YYGReport *)report;
//
//// New API
//
//- (void)reportsWithHandler:(void(^)(NSArray<YYGReport *> * _Nullable result,
//                                    NSString * _Nullable message))handler;


@end

NS_ASSUME_NONNULL_END
