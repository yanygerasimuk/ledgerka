//
//  YGOperationTwoRowCell.h
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGOperationTwoRowCell : UITableViewCell

@property (copy, nonatomic) NSString *firstRowText;
@property (copy, nonatomic) NSString *firstRowDetailText;
@property (copy, nonatomic) NSString *secondRowText;
@property (copy, nonatomic) NSString *secondRowDetailText;
@property (assign, nonatomic) YGOperationType type;

@end
