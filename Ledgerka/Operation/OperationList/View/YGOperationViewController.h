//
//  YGOperationViewController.h
//  Ledger
//
//  Created by Ян on 12/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGOperationEditController.h"
#import "YYGOperationPermissionViewModel.h"

@interface YGOperationViewController : UITableViewController

/// Public for use in +actions category
@property (nonatomic, strong) YYGOperationPermissionViewModel *permissionViewModel;

@end
