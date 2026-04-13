//
//  AppDelegate.m
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "AppDelegate.h"
#import "YGSQLite.h"
#import "YGDBManager.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"
#import "YYGDBConfig.h"
#import "YGConfig.h"
#import "YYGUpdater.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface AppDelegate()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#ifdef DEBUG_IS_FIRST_LAUNCH
    [userDefaults removeObjectForKey:kIsFirstLaunch];
#endif
    // First or casual launch flow
    if(![userDefaults objectForKey:kIsFirstLaunch]
       || [[userDefaults valueForKey:kIsFirstLaunch] boolValue] == NO) {
        [userDefaults setBool:YES forKey:kIsFirstLaunch];
        [self firstLaunch];
    }
    
    // Save current device screen size in defaults
    UIScreen *screen = [UIScreen mainScreen];
    [userDefaults setObject:@((NSInteger)[screen bounds].size.width) forKey:kDeviceScreenWidth];
    [userDefaults setObject:@((NSInteger)[screen bounds].size.height) forKey:kDeviceScreenHeight];
    
    // Check database exists and create if neccessary
    YGDBManager *dm = [YGDBManager sharedInstance];
    if(![dm isDatabaseFileExists])
        [dm createDatabase];
    
    // Update environment if neccessary
    YYGUpdater *updater = [[YYGUpdater alloc] init];
    [updater checkEnvironment];
    
    // Dropbox setup
    [DBClientsManager setupWithAppKey:kDropboxAppKey];
    
    return YES;
}

/**
 First launch, specific flow.
 */
- (void)firstLaunch {
#ifdef DEBUG_REBUILD_DATABASE
    YGDBManager *dm = [YGDBManager sharedInstance];
    [dm deleteDatabaseFile];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
#ifdef DEBUG
    NSLog(@"application:openURL:options:...");
    NSLog(@"openURL: %@", url);
#endif
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    return NO;
}

/**
 Load main UI after Launch UIViewController and background tasks finish work.
 */
- (void)loadMainUI {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    UIView *snapshot = [self.window snapshotViewAfterScreenUpdates:true];
    [vc.view addSubview:snapshot];
    
    self.window.rootViewController = vc;
    
    [UIView animateWithDuration:1.0 animations:^{
        snapshot.layer.opacity = 0.0f;
        snapshot.layer.transform = CATransform3DMakeScale(1.5f, 1.5f, 1.5f);
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
    }];
    
    [self.window makeKeyAndVisible];
}

@end
