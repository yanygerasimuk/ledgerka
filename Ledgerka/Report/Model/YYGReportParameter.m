//
//  YYGReportParameter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportParameter.h"


@implementation YYGReportParameter

- (instancetype)initWithRowId:(NSInteger)rowId
                         type:(YYGReportParameterType)type
                  reportRowId:(NSInteger)reportRowId
                         uuid:(NSUUID *)uuid
{
    self = [super init];
    if (self)
    {
        // DB object
        _rowId = rowId;
        _type = type;
        _reportRowId = reportRowId;
        _uuid = [uuid copy];

        // Complex object
        _values = [NSMutableArray <YYGReportValue *> new];
    }
    return self;
}


#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {

    if(self == object) return YES;

    if([self class] != [object class]) return NO;
    
    YYGReportParameter *otherParameter = (YYGReportParameter *)object;
    if (self.rowId != otherParameter.rowId)
        return NO;
    if (self.type != otherParameter.type)
        return NO;
    if (self.reportRowId != otherParameter.reportRowId)
        return NO;
    if (self.uuid != otherParameter.uuid)
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%ld:%@",
                            (long)_rowId,
                            (long)_type,
                            (long)_reportRowId,
                            _uuid];

    return [hashString hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ReportParameter | RowId:%ld, type:%@, reportRowId:%ld",
            (long)_rowId,
            NSStringFromReportParameterType(_type),
            (long)_reportRowId];
}


#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    YYGReportParameter *newParameter = [[YYGReportParameter alloc]
                                        initWithRowId:_rowId
                                        type:_type
                                        reportRowId:_reportRowId
                                        uuid:_uuid];
    return newParameter;
}

@end


NSString * NSStringFromReportParameterType(YYGReportParameterType type)
{
    switch (type)
    {
        case YYGReportParameterTypeDate:
            return @"Дата";
        case YYGReportParameterTypeAccount:
            return @"Счёт";
        default:
            @throw [NSException exceptionWithName:@"YYGReportParameter NSStringFromReportParameterType()" reason:@"Unknown report parameter type." userInfo:nil];
    }
}
