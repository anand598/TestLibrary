//
//  ScanShopResultsViewController.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/16/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ScanShopSelectionDelegate.h>
#import <SyndecaSDK/ScanShopResultsDelegate.h>
#import <SyndecaSDK/IssueModel.h>
#import <SyndecaSDK/DependencyInjection.h>

/** Controls the result of a scan and shop action as detailed in https://synapsegroup.jira.com/browse/SYN-1660 */
@interface ScanShopResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DependencyInjection>

/** A delegate to proxy user selection results to. */
@property (readwrite) id<ScanShopResultsDelegate> delegate;
@property (readwrite) id<ScanShopSelectionDelegate> selectionDelegate;


/** If set to YES, the ScanShopResultsViewController will automatically
 handle product, video and external link selection using views and controllers
 within the SyndecaSDK.
 
 The default is NO.
 */
@property (readwrite) BOOL handleProductVideoAndExternalLinkSelection;

- (id)initWithCatalog:(IssueModel*)issue andPageIndex:(NSUInteger)ndx;
- (id)initWithBarcode:(NSString*)barcode;

@end

