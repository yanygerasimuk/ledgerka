//
//  YYGDebtSelectViewModel.h
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitySelectViewModel.h"

@interface YYGDebtSelectViewModel : YYGEntitySelectViewModel <YYGEntitySelectViewModelable>

- (NSString *)title;
- (NSArray <YGEntity *> *)getEntities;
- (BOOL)showDetailText;
- (NSString *)textOf:(YGEntity *)entity;
- (NSString *)detailTextOf:(YGEntity *)entity;
- (NSString *)unwindSegueName;
@end
