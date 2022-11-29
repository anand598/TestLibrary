//
//  WebNavigationControllerDelegate.h
//  Justice
//
//  Created by Schell Scivally on 4/6/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebNavigationController;
/* Communicates between controllers that present WebViewControllers, sometimes needed to dismiss web view depending on where you are in the stack - mostly ScanShopViewController */
@protocol WebNavigationControllerDelegate <NSObject>

- (void)didRequestDismissalFromWebNavigationController:(WebNavigationController*)controller;
@end
