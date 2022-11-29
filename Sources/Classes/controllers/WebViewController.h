//
//  WebViewController.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SyndecaSDK/WebNavigationControllerDelegate.h>
#import <SyndecaSDK/ScanShopResultsDelegate.h>

/** A WebViewController is a simple controller that allows web browsing,
 starting at a specific URL. It displays an UIActivityIndicatorView as
 the right bar button item and sets it animating whenever loading begins. 
 */
@interface WebViewController : UIViewController <WKNavigationDelegate>

@property (readwrite) UIActivityIndicatorView* indicatorView;
- (id)initWithRequest:(NSURLRequest*)request;

/** A script used to modify the view of the browser */
@property (readwrite) NSString* clientScript;
/** A delegate to handle navigation for the ScanShopViewController */
@property (readwrite) id<WebNavigationControllerDelegate> delegate;
/*This property allows you to override the hmaburger menu button and show a back button. Only set this to true if you are presenting this as a view controller from some other view in your app heirarchy**/
@property (readwrite) BOOL shouldShowBackButton;
@property (readwrite) BOOL isFromHamburgerMenu;
@property (readwrite) BOOL isFromMoreView;
@property (readwrite) BOOL isFromScanView;
@property (readwrite) id<ScanShopResultsDelegate> scanShopDelegate;
@property (readwrite) BOOL shouldReloadOnViewDidAppear;

@end
