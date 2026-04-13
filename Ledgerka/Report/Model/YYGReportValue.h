//
//  YYGReportValue.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YYGReportValueType)
{
    YYGReportValueTypeText        = 1,    /**< Text */
    YYGReportValueTypeDate        = 2,    /**< Date */
    YYGReportValueTypeBool        = 3,    /**< Bool */
    YYGReportValueInteger        = 4,    /**< Integer */
    YYGReportValueFloat            = 5        /**< Float */
};

NSString * _Nonnull NSStringFromReportValueType(YYGReportValueType type);


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportValue : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger rowId;
@property (nonatomic, assign) YYGReportValueType type;
@property (nonatomic, assign) NSInteger parameterId;
@property (nonatomic, nullable, copy) NSString *valueText;
@property (nonatomic, assign) BOOL valueBool;
@property (nonatomic, assign) NSInteger valueInteger;
@property (nonatomic, assign) double valueFloat;
@property (nonatomic, copy) NSUUID *uuid;

- (instancetype)initWithRowId:(NSInteger)rowId
                         type:(YYGReportValueType)type
                  parameterId:(NSInteger)parameterId
                    valueText:(NSString *)valueText
                    valueBool:(BOOL)valueBool
                 valueInteger:(NSInteger)valueInteger
                   valueFloat:(double)valueFloat
                         uuid:(NSUUID *)uuid;

@end

NS_ASSUME_NONNULL_END
