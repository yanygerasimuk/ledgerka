//
//  YGCategory.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGObject.h"

typedef NS_ENUM(NSInteger, YGCategoryType){
    YGCategoryTypeCurrency          = 1,
    YGCategoryTypeExpense           = 2,
    YGCategoryTypeIncome            = 3,
    YGCategoryTypeCounterparty      = 4,
    YGCategoryTypeTag               = 5
};

NSString *NSStringFromCategoryType(YGCategoryType type);

@interface YGCategory : NSObject <NSCopying, YYGRowIdAndNameIdentifiable>

@property (assign, nonatomic) NSInteger rowId;
@property (assign, nonatomic, readonly) YGCategoryType type;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic, getter=isActive) BOOL active;
@property (copy, nonatomic) NSDate *created;
@property (copy, nonatomic) NSDate *modified;
@property (assign, nonatomic) NSInteger sort;
@property (copy, nonatomic) NSString *symbol;
@property (assign, nonatomic, getter=isAttach) BOOL attach;
@property (assign, nonatomic) NSInteger parentId;
@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSUUID *uuid;

/**
 Base init for Category.
 */
- (instancetype)initWithRowId:(NSInteger)rowId categoryType:(YGCategoryType)type name:(NSString *)name active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified sort:(NSInteger)sort symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment uuid:(NSUUID *)uuid;

/**
 Convinience init for new currency, not saved in db yet.
 */
- (instancetype)initWithType:(YGCategoryType)type name:(NSString *)name sort:(NSInteger)sort symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment;

- (NSString *)shorterName;

@end
