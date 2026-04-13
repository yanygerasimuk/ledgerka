//
//  YGOperationSection.h
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YGOperation;
@class YGOperationRow;
@class YGOperationSectionHeader;

@interface YGOperationSection : NSObject

/// custom view for section header
// @property (strong, nonatomic) YGOperationSectionHeader *headerView;

/// name of section in human view
@property (copy, nonatomic, readonly) NSString *name;

/// opertions of this section
@property (strong, nonatomic, readonly) NSArray <YGOperationRow *> *operationRows;

/// date in format 'yyyy-MM-dd'
@property NSDate *date;

- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithDate:(NSDate *)date operationRows:(NSMutableArray <YGOperationRow *>*)operationRows;
- (void)addOperationRow:(YGOperationRow *)operationRow;
- (void)setOperationRows:(NSMutableArray <YGOperationRow *>*)operationRows;
@end
