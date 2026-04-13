//
//  YGDropboxLinkViewController.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGDropboxLinkViewController.h"
#import "YYGBackupViewController.h"
#import "YGOptionViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface YGDropboxLinkViewController ()

@property (weak, nonatomic) IBOutlet UIButton *linkDropboxButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
- (IBAction)linkDropboxButtonPressed:(UIButton *)sender;
@end

@implementation YGDropboxLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"DROPBOX_ACCOUNT_TITLE", @"Account");
    
    // Link button
    UIColor *buttonColor = [UIColor colorWithRed:3.0f/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    [self.linkDropboxButton.titleLabel setTextColor:buttonColor];
    self.linkDropboxButton.titleLabel.textColor = buttonColor;
    self.linkDropboxButton.layer.borderColor = [buttonColor CGColor];
    self.linkDropboxButton.layer.borderWidth = 1.5f;
    self.linkDropboxButton.layer.cornerRadius = 8.0f;
    
    [self checkButtons];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkButtons {
    
    [self setInfoText];
    [self setLinkDropboxButtonTitle];
    
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        if (_target) {
            if ([_target isEqualToString:@"BackupDB"]) {

                [self.navigationController popViewControllerAnimated:YES];
                
                YYGBackupViewController *dropboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGBackupViewController"];
                dropboxVC.viewModel = [YYGBackupViewModel viewModelWith:YYGStorageTypeDropbox];
                
                [self.navigationController pushViewController:dropboxVC animated:YES];
            }
        }
    }
}

- (IBAction)linkDropboxButtonPressed:(UIButton *)sender {
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        
        [DBClientsManager unlinkAndResetClients];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        YGOptionViewController *optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YGOptionViewController"];
#pragma clang diagnostic pop
        
        for(UIViewController *tempVC in [self.navigationController viewControllers]) {
            if([tempVC isKindOfClass: [YGOptionViewController class]]) {
                YGOptionViewController *optionsVC = (YGOptionViewController *)tempVC;
                [optionsVC setDelayedMethod:@"LinkDropbox"];
                
                [self.navigationController popToViewController:optionsVC animated:YES];
                
                break;
            }
        }
    } else {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:[[self class] topMostController]
                                          openURL:^(NSURL *url) {
            [[UIApplication sharedApplication] openURL:url
                                               options:[NSDictionary dictionary]
                                     completionHandler:^(BOOL success) {
                                                  
                //NSLog(@"openURL complete");
            }];
        }];
    }
}

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)setLinkDropboxButtonTitle {
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        [_linkDropboxButton setTitle:NSLocalizedString(@"DROPBOX_ACCOUNT_UNLINK_BUTTON", @"Unlink Dropbox account") forState:UIControlStateNormal];
    } else {
        [_linkDropboxButton setTitle:NSLocalizedString(@"DROPBOX_ACCOUNT_LINK_BUTTON", @"Link Dropbox account") forState:UIControlStateNormal];
    }
}

- (void)setInfoText {
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        // Text
        NSString *text = NSLocalizedString(@"DROPBOX_TO_UNLINK_ACCOUNT_TEXT", @"Help text for unlink dropbox account.");
        NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}];
        
        self.infoLabel.attributedText = textAttr;
    } else {
        // Text
        NSString *text = NSLocalizedString(@"DROPBOX_TO_LINK_ACCOUNT_TEXT", @"Help text for link dropbox account.");
        NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}];
        
        self.infoLabel.attributedText = textAttr;
    }
}

@end
