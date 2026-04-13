//
//  YGAccountActualEditController.h
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGAccountActualEditController : UITableViewController 

@property (copy, nonatomic) YGOperation *accountActual;
@property (assign, nonatomic) BOOL isNewAccountAcutal;
@end
