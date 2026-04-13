//
//  YGEntity.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGObject.h"

typedef NS_ENUM(NSInteger, YGEntityType) {
    YGEntityTypeAccount = 1,
    YGEntityTypeDebt    = 2
};

typedef NS_ENUM(NSInteger, YYGCounterpartyType) {
    YYGCounterpartyTypeNone     = 0,
    YYGCounterpartyTypeDebtor   = 1,
    YYGCounterpartyTypeCreditor = 2
};

NSString * NSStringFromEntityType(YGEntityType type);
NSString * NSStringFromCounterpartyType(YYGCounterpartyType type);

@interface YGEntity : NSObject <NSCopying, YYGRowIdAndNameIdentifiable, YYGSumAndCurrencyIdentifiable>

@property (nonatomic, assign) NSInteger rowId;
@property YGEntityType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double sum;
@property (nonatomic, assign) NSInteger currencyId;
@property (getter=isActive) BOOL active;
@property NSDate *created;
@property NSDate *modified;
@property (assign, nonatomic, getter=isAttach) BOOL attach;
@property NSInteger sort;
@property NSString *comment;
@property NSUUID *uuid;
@property NSInteger counterpartyId;
@property YYGCounterpartyType counterpartyType;

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment uuid:(NSUUID *)uuid counterpartyId:(NSInteger)counterpartyId counterpartyType:(YYGCounterpartyType)counterpartyType;

- (instancetype)initWithType:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment counterpartyId:(NSInteger)counterpartyId counterpartyType:(YYGCounterpartyType)counterpartyType;
@end
