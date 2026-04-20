//
//  YYGTableViewControllerOutput.h
//  Ledger
//
//  Created by Yan Gerasimuk on 18.07.2024.
//  Copyright © 2024 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import "YYGReportListViewModel.h"



@protocol YYGTableViewControllerOutput

- (void)viewDidLoad;
- (void)viewDidAppear;
- (void)didPullRefresh;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
