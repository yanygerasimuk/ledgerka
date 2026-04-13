//
//  YGOptionViewController.h
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYGDelayedCalling
- (void)setDelayedMethod:(NSString *)method;
@end

@interface YGOptionViewController : UITableViewController <YYGDelayedCalling>

- (void)setDelayedMethod:(NSString *)method;

@end
