//
//  YGEntityViewController.h
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGEntity.h"
#import "YYGEntitiesViewModel.h"

@interface YGEntityViewController : UITableViewController

@property (strong, nonatomic, readonly) id<YYGEntitiesViewModelable> viewModel;

@end
