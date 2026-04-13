//
//  YGOperationRow.h
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YGOperation;

@interface YGOperationRow : NSObject

@property (strong, nonatomic) YGOperation *operation;

/// cache source
@property (strong, nonatomic) NSString *source;
/// cache source sum
@property (strong, nonatomic) NSString *sourceSum;
/// cache target
@property (strong, nonatomic) NSString *target;
/// cache target sum
@property (strong, nonatomic) NSString *targetSum;

- (instancetype)initWithOperation:(YGOperation *)operation;
@end
