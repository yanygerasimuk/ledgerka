//
//  YGOperationSectionManager.h
//  Ledger
//
//  Created by Ян on 04.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOperationSection.h"
#import "YGOperationManager.h"
#import "YGOperation.h"

@interface YGOperationSectionManager : NSObject <OperationSectionProtocol>

@property (nonatomic, strong, readonly) NSMutableArray <YGOperationSection *> *sections;

+ (instancetype)sharedInstance;

- (void)addOperation:(YGOperation *)operation;
- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation;
- (void)removeOperation:(YGOperation *)operation;

- (void)makeSections;
@end
