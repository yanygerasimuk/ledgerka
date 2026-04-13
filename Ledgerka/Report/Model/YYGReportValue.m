//
//  YYGReportValue.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportValue.h"


@implementation YYGReportValue

- (instancetype)initWithRowId:(NSInteger)rowId
                         type:(YYGReportValueType)type
                  parameterId:(NSInteger)parameterId
                    valueText:(NSString *)valueText
                    valueBool:(BOOL)valueBool
                 valueInteger:(NSInteger)valueInteger
                   valueFloat:(double)valueFloat
                         uuid:(NSUUID *)uuid

{
    self = [super init];
    if (self)
    {
        _rowId = rowId;
        _type = type;
        _parameterId = parameterId;
        _valueText = [valueText copy];
        _valueBool = valueBool;
        _valueInteger = valueInteger;
        _valueFloat = valueFloat;
        _uuid = [uuid copy];
    }
    return self;
}


#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {

    if(self == object) return YES;

    if([self class] != [object class]) return NO;
    
    YYGReportValue *otherValue = (YYGReportValue *)object;
    if (self.rowId != otherValue.rowId)
        return NO;
    if (self.type != otherValue.type)
        return NO;
    if (self.parameterId != otherValue.parameterId)
        return NO;
    if (![self.valueText isEqualToString:otherValue.valueText])
        return NO;
    if (self.valueBool != otherValue.valueBool)
        return NO;
    if (self.valueInteger != otherValue.valueInteger)
        return NO;
    if (self.valueFloat != otherValue.valueFloat)
        return NO;
    if (self.uuid != otherValue.uuid)
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%ld:%@:%ld:%ld:%f:%@",
                            (long)_rowId,
                            (long)_type,
                            (long)_parameterId,
                            _valueText,
                            (long)_valueBool,
                            (long)_valueInteger,
                            _valueFloat,
                            _uuid];

    return [hashString hash];
}

- (NSString *)description
{
    NSString *value;
    switch (_type)
    {
        case YYGReportValueTypeText:
            value = _valueText;
            break;
        case YYGReportValueTypeBool:
            value = _valueBool ? @"Да" : @"Нет";
            break;
        case YYGReportValueInteger:
            value = [NSString stringWithFormat:@"%ld", (long)_valueInteger];
            break;
        case YYGReportValueFloat:
            value = [NSString stringWithFormat:@"%f", _valueFloat];
            break;
        default:
            value = @"UnKnown";
    }
    
    return [NSString stringWithFormat:@"ReportValue RowId:%ld, type:%@, parameterId:%ld, value:%@",
            (long)_rowId,
            NSStringFromReportValueType(_type),
            (long)_parameterId,
            value];
}


#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    YYGReportValue *newValue = [[YYGReportValue alloc] 
                                initWithRowId:_rowId
                                type:_type
                                parameterId:_parameterId
                                valueText:_valueText
                                valueBool:_valueBool
                                valueInteger:_valueInteger
                                valueFloat:_valueFloat
                                uuid:_uuid];
    return newValue;
}

@end


NSString * NSStringFromReportValueType(YYGReportValueType type)
{
    switch (type)
    {
        case YYGReportValueTypeText:
            return @"Текст";
        case YYGReportValueTypeDate:
            return @"Дата";
        case YYGReportValueTypeBool:
            return @"Булевый";
        case YYGReportValueInteger:
            return @"Целый";
        case YYGReportValueFloat:
            return @"Дробный";
        default:
            @throw [NSException exceptionWithName:@"YYGReportValue NSStringFromReportValueType()"
                                           reason:@"Unknown report value type."
                                         userInfo:nil];
    }
}
