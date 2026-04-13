//
//  YGDropboxLinkViewController.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGDropboxLinkViewController : UIViewController

/// Target name for navigate, may be exportCSV or backupDB
@property (copy, nonatomic) NSString *target;

@end
