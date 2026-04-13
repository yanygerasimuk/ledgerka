//
//  YGOperationRow.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationRow.h"
#import "YGOperation.h"

@implementation YGOperationRow

- (instancetype)initWithOperation:(YGOperation *)operation {
    self = [super init];
    if(self){
        _operation = operation;
    }
    return self;
}
@end
