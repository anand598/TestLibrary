//
//  ScanShopResultsDelegate.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/16/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ScanShopResult.h>

@class ScanShopResultsViewController;

@protocol ScanShopResultsDelegate <NSObject>

/** Called by the ScanShopViewController and ScanShopResultsViewController when the user selects a result. */
- (void)didSelectResult:(ScanShopResult*)result inResultController:(id)controller;

/** Called by the ScanShopViewController and ScanShopResultsViewController when the user hits the back button while
 viewing displayed results. */
@optional
- (void)didDismissResultsController:(id)controller;


@end
