//
//  YGOperationSection.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSection.h"
#import "YGOperation.h"
#import "YGOperationRow.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGOperationSection () {
    NSMutableArray <YGOperationRow *> *_operationRows;
}
+(NSString *)nameOfDateInHumanView:(NSDate *)date;
@end

@implementation YGOperationSection

@synthesize name = _name;

+ (NSString *)nameOfDateInHumanView:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru_RU"]];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
}

- (instancetype)initWithDate:(NSDate *)date operationRows:(NSMutableArray *)operationRows {
    if(self = [super init]) {
        _date = [date copy];
        if(operationRows)
            _operationRows = operationRows;
        else
            _operationRows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date {
    return [self initWithDate:date operationRows:nil];
}

// lazy
- (NSString *)name {
    if(!_name)
        _name = [YGTools humanViewShortWithTodayOfDay:_date];
    return _name;
}

- (void)addOperationRow:(YGOperationRow *)operationRow {
    [_operationRows addObject:operationRow];
    [self sortOperationRows];
}

- (void)sortOperationRows {
    NSSortDescriptor *sortOnModifiedByDesc = [[NSSortDescriptor alloc] initWithKey:@"operation.modified" ascending:NO];
    [_operationRows sortUsingDescriptors:@[sortOnModifiedByDesc]];
}

//- (YGOperationSectionHeader *)headerView {
//    if (!_headerView)
//        _headerView = [[YGOperationSectionHeader alloc] initWithSection:self];
//    return _headerView;
//}

- (void)setOperationRows:(NSMutableArray <YGOperationRow *>*)operationRows {
    _operationRows = operationRows;
    [self sortOperationRows];
}
@end
