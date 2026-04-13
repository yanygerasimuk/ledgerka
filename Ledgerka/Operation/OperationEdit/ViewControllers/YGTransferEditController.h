//
//  YGTransferEditController.h
//  Ledger
//
//  Created by Ян on 23/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGTransferEditController : UITableViewController 

@property (copy, nonatomic) YGOperation *transfer;
@property (assign, nonatomic) BOOL isNewTransfer;
@end
