//
//  YYGDebtSelectViewModel.m
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtSelectViewModel.h"

@implementation YYGDebtSelectViewModel

- (NSString *)title {
    return NSLocalizedString(@"ENTITY_SELECT_FORM_SELECT_DEBT_TITLE", @"Title for select debt in select entity form");
}

- (NSArray <YGEntity *> *)getEntities {
    return [super activeEntitiesOf:YGEntityTypeDebt];
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
            @throw [NSException exceptionWithName:@"YYGDebtSelectViewModel unwindSegueName fails." reason:@"Unknown customer of entity select." userInfo:nil];
    }
}

@end
