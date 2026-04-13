//
//  YYGAccountSelectViewModel.m
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGAccountSelectViewModel.h"

@implementation YYGAccountSelectViewModel

- (NSString *)title {
    return NSLocalizedString(@"ENTITY_SELECT_FORM_SELECT_ACCOUNT_TITLE", @"Title for select account in select entity form");
}

- (NSArray <YGEntity *> *)getEntities { 
    return [super activeEntitiesOf:YGEntityTypeAccount];
}

- (BOOL)showDetailText {
    return YES;
}

- (NSString *)textOf:(YGEntity *)entity {
    return entity.name;
}

- (NSString *)detailTextOf:(YGEntity *)entity {
    return [super detailTextOf:entity];
}

- (NSString *)unwindSegueName {
    switch(self.customer) {
        case YYGEntitySelectForOperationEditSource:
            return @"unwindFromSourceEntitySelectToOperationEdit";
            break;
        case YYGEntitySelectForOperationEditTarget:
            return @"unwindFromTargetEntitySelectToOperationEdit";
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGAccountSelectViewModel unwindSegueName fails." reason:@"Unknown customer of account select." userInfo:nil];
    }
}

@end
