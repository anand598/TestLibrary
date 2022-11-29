//
//  AppDelegate.h
//  Default
//
//  Created by Schell on 11/7/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DefaultAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Client Config
/** Configures the SyndecaSDK for this app. 
 Client specific subclasses should override this to inject their Syndeca data
 and configuration.
 */
- (void)configureApp;
- (void)startupUrbanAirship;

@end
