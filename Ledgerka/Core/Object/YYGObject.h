//
//  YYGObject.h
//  Ledger
//
//  Created by Ян on 05.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

@protocol YYGRowIdAndNameIdentifiable <NSObject, NSCopying>
@property (nonatomic, assign) NSInteger rowId;
@property (nonatomic, copy) NSString *name;
@end

@protocol YYGSumAndCurrencyIdentifiable
@property (nonatomic, assign) double sum;
@property (nonatomic, assign) NSInteger currencyId;
@end

@protocol YYGViewModelable
@property (nonatomic, strong) id viewModel;
@end
