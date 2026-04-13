//
//  YYGOperationEditController.h
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGOperationEditViewModel.h"

@interface YYGOperationEditController : UITableViewController

@property (nonatomic, strong) id<YYGOperationEditViewModelable> viewModel;

@end
