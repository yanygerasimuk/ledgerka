//
//  YGOperation.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperation.h"

@implementation YGOperation

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment uuid:(NSUUID *)uuid {
    
    self = [super init];
    if(self) {
        _rowId = rowId;
        _type = type;
        _sourceId = sourceId;
        _targetId = targetId;
        _sourceSum = sourceSum;
        _sourceCurrencyId = sourceCurrencyId;
        _targetSum = targetSum;
        _targetCurrencyId = targetCurrencyId;
        
        if(day)
            _day = [day copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId:type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:day:created:modified:comment:uuid:" reason:@"Day of operation can not be null" userInfo:nil];
        
        if(created)
            _created = [created copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId:type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:day:created:modified:comment:" reason:@"Created date of operation can not be null" userInfo:nil];
        
        if(modified)
            _modified = [modified copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId:type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:day:created:modified:comment:uuid:" reason:@"Modified date of operation can not be null" userInfo:nil];
    
        if(comment)
            _comment = [comment copy];

        if(uuid)
            _uuid = [uuid copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId:type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:day:created:modified:comment:uuid:" reason:@"UUID of operation can not be null" userInfo:nil];
    }
    return self;
}

/**
 Convinience init only for new (not saved in db) operation.
 */
- (instancetype)initWithType:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment {
    
    return [self initWithRowId:-1 type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId day:day created:created modified:modified comment:comment uuid:[NSUUID UUID]];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"Operation. RowId: %ld, type: %ld, sourceId: %ld, targetId: %ld, sourceSum: %.f, sourceCurrencyId: %ld, targetSum: %.2f, targetCurrencyId: %ld, day: %@, created: %@, modified: %@, comment: %@, uuid: %@", (long)_rowId, (long)_type, (long)_sourceId, (long)_targetId, _sourceSum, (long)_sourceCurrencyId, _targetSum, (long)_targetCurrencyId, _day, _created, _modified, _comment, _uuid];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    
    YGOperation *newOperation = [[YGOperation alloc] initWithRowId:_rowId type:_type sourceId:_sourceId targetId:_targetId sourceSum:_sourceSum sourceCurrencyId:_sourceCurrencyId targetSum:_targetSum targetCurrencyId:_targetCurrencyId day:_day created:_created modified:_modified comment:_comment uuid:_uuid];
    
    return newOperation;
}

#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {
    
    if(self == object) return YES;
    
    if([self class] != [object class]) return NO;
    
    YGOperation *otherOperation = (YGOperation *)object;
    
    if(self.rowId != otherOperation.rowId)
        return NO;
    if(self.type != otherOperation.type)
        return NO;
    if(self.sourceId != otherOperation.sourceId)
        return NO;
    if(self.targetId != otherOperation.targetId)
        return NO;
    if(self.sourceSum != otherOperation.sourceSum)
        return NO;
    if(self.targetSum != otherOperation.targetSum)
        return NO;
    if(![self.day isEqual:otherOperation.day])
        return NO;
    if(![self.created isEqual:otherOperation.created])
        return NO;
    if(![self.uuid isEqual:otherOperation.uuid])
        return NO;

    return YES;
}

- (NSUInteger)hash {
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%ld:%f:%ld:%f:%@:%@:%@", (long)_type, (long)_rowId, (long)_sourceId, _sourceSum, (long)_targetId, _targetSum, _day, _created, _uuid];
    return [hashString hash];
}

@end
