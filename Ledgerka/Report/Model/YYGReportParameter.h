//
//  YYGReportParameter.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportValue.h"


typedef NS_ENUM(NSInteger, YYGReportParameterType)
{
    YYGReportParameterTypeDate        = 1,    /**< Дата */
    YYGReportParameterTypeAccount    = 2        /**< Счёт */
};

NSString * _Nonnull NSStringFromReportParameterType(YYGReportParameterType type);


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportParameter : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger rowId;
@property (nonatomic, assign) YYGReportParameterType type;
@property (nonatomic, assign) NSInteger reportRowId;
@property (nonatomic, copy) NSUUID *uuid;

- (instancetype)initWithRowId:(NSInteger)rowId
                         type:(YYGReportParameterType)type
                  reportRowId:(NSInteger)reportRowId
                         uuid:(NSUUID *)uuid;

// Complex object
@property (nonatomic, strong) NSMutableArray <YYGReportValue *> *values;

@end

NS_ASSUME_NONNULL_END
