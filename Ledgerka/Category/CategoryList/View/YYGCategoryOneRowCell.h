//
//  YYGCategoryOneRowCell.h
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"

extern NSString *const kCategoryOneRowCellId;

@interface YYGCategoryOneRowCell : UITableViewCell

@property (copy, nonatomic) NSString *textLeft;
@property (copy, nonatomic) NSString *textRight;

@property (copy, nonatomic) UIColor *colorTextLeft;
@property (copy, nonatomic) UIColor *colorTextRight;

@property (assign, nonatomic) YGCategoryType type;

@end
