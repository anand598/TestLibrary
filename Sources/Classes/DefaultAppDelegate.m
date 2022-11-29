//
//  AppDelegate.m
//  Default
//
//  Created by Schell on 11/7/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "DefaultAppDelegate.h"
#import "SyndecaTabBarController.h"
#import "SyndecaRevealViewController.h"
#import "HamburgerMenuViewController.h"
#import "SyndecaSDK.h"
#import "MasterConfiguration.h"
#import "FIRTrackProxy.h"
#import "NetworkStatusObserver.h"
#import "AFNetworking.h"
@import FirebaseCore;

@implementation DefaultAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[SyndecaConfig class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self startupUrbanAirship];
    [[NetworkStatusObserver sharedObserver] start];
    
    [FIRApp configure];
    
//    The Hamburger Menu View Controller is a custom view controller that allows a pop-over menu from the left or right. Please look within this file for further documentation.
    SyndecaTabBarController *frontViewController = [SyndecaTabBarController sharedController];
    HamburgerMenuViewController *rearViewController = [[[HamburgerMenuViewController DIClass] alloc] init];
    rearViewController.syndecaTabBarController = frontViewController;
    
    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    rearNavigationController.navigationBar.hidden = YES;
    SyndecaRevealViewController *revealController = [[SyndecaRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontViewController];
    revealController.delegate = self;
    [self.window makeKeyAndVisible];

//    Here we either set our root view controller as the hamburger menu controller, or just the tab bar controller.
    self.window.rootViewController = revealController;
    return YES;
}

/** Left blank for subclasses to override. */
- (void)configureApp {
}

#pragma mark - Remote Notifications

- (void)startupUrbanAirship {

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Registered for notifications with token:%@",deviceToken);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received push notification with userInfo:%@", userInfo);
}
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state {
    NSLog(@"Received push notification with notification:%@", notification);
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FIRTrackProxy sharedProxy] trackAppClose];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[FIRTrackProxy sharedProxy] trackAppOpen];
    [[FIRTrackProxy sharedProxy] trackViewPage];
    SyndecaTabBarController* s = [SyndecaTabBarController sharedController];
    if ([s.viewControllers count] == 1) {
        [s loadRootPublication];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //[[ScanShopViewController scanner] close:nil];
}

@end
