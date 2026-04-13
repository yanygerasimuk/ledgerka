//
//  YYGExpenseViewModel.h
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryViewModel.h"

@interface YYGExpenseViewModel : YYGCategoryViewModel <YYGCategoryViewModelable>

@property (copy, nonatomic) YGCategory *parent;

@end
