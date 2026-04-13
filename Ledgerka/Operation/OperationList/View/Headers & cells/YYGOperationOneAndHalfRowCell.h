//
//  YYGOperationOneAndHalfRowCell.h
//  Ledger
//
//  Created by Ян on 19.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YYGOperationOneAndHalfRowCell : UITableViewCell

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSString *sum;
@property (nonatomic, assign) YGOperationType type;

@end





