//
//  YYGEntitySelectController.h
//  Ledger
//
//  Created by Ян on 18.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGEntitySelectViewModel.h"

@interface YYGEntitySelectController : UITableViewController

@property (nonatomic, strong) id<YYGEntitySelectViewModelable> viewModel;

@end
