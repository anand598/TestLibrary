//
//  SyndecaTabBarController.h
//  Syndeca iOS SDK
//
//  Created by Schell on 4/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SyndecaSDK/SyndecaSDK.h>
#import <SyndecaSDK/GuideViewController.h>
#import <SyndecaSDK/TOCController.h>
#import <SyndecaSDK/CatalogViewController.h>
#import <SyndecaSDK/ShoppingCartController.h>
#import <SyndecaSDK/TrackingPanel.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/ScanShopViewController.h>
#import <SyndecaSDK/SyndecaTabBarController.h>
#import <MessageUI/MessageUI.h>

@interface SyndecaTabBarController : UITabBarController <MFMailComposeViewControllerDelegate, UITabBarControllerDelegate, WebNavigationControllerDelegate, ScanShopResultsDelegate, ItemSelectionDelegate, ProductDetailViewDelegate, UITableViewDelegate, CatalogLinkDelegate>

+ (SyndecaTabBarController*)sharedController;
+ (void)setSharedController:(SyndecaTabBarController*)sharedController;

/** The guide screen controller. */
@property (readwrite) CatalogViewController* rootPublicationController;
@property (readwrite) ShoppingCartController* addToBagController;
@property (readwrite) ShoppingCartController* wishlistController;
@property (readwrite) ScanShopViewController* scanShopController;
@property (readwrite) WebNavigationController* storeLocatorsController;
@property (readwrite) WebNavigationController* webRequestQuoteController;
@property (readwrite) WebNavigationController* webCustomerPortalController;
@property (readwrite) WebNavigationController* webADSEventsController;
@property (readwrite) WebNavigationController* webADSFeedbackController;
@property (readwrite) GuideViewController* guideController;


@property (readwrite) bool suspendReloadingPublications;
@property (readwrite) bool shouldShowGuide;


@property (readwrite) MFMailComposeViewController* mailController;
@property (readwrite) TrackingPanel* trackingPanel;
/** The catalog screen controller. */
@property (readwrite) CatalogViewController* catalogController;
/** The table of contents screen controller. */
@property (readwrite) TOCController* tocController;
/** A controller for our standard bag web view. */
@property (readwrite) UINavigationController* webController;

@property (readwrite) UINavigationController* webFavoritesController;

/** A toolbar for extra UI. */
@property (readwrite) UIToolbar* toolbar;
/** A fake toolbar to make our toolbar look nice. */
@property (readwrite) UIToolbar* fauxbar;
/** A container to make the toolbar look nice. */
@property (readwrite) UIView* toolbarContainer;

@property (readwrite) WKProcessPool* processPool;

@property (assign) id <UITableViewDelegate> originalTabBarMoreControllerTableViewDelegate;

#pragma mark - Cart
- (void)exportItemsFrom:(ShoppingCart*)cart;

#pragma mark - Factories

- (ShoppingCartController*)newAddToBagController;
- (ShoppingCartController*)newWishlistController;
- (PublicationController*)newPublicationController;
- (CatalogViewController*)newCatalogController;
- (CatalogViewController*)newRootPublicationController;
- (WebNavigationController*)newWebController;
- (TOCController*)newTOCController;
- (ScanShopViewController*)newScanShopController;
- (WebNavigationController*)newWebFavoritesController;
- (WebNavigationController*)newWebRequstQuoteController;
- (WebNavigationController*)newCustomerPortalController;
- (WebNavigationController*)newADSEventsController;
- (WebNavigationController*)newADSFeedBackController;
#pragma mark - Reset

- (void)loadRootPublication;
- (void)resetToGuide;

#pragma mark - Catalog Operations

/** Loads an issue into the catalog screen and toc screen.
 @see https://synapsegroup.jira.com/browse/SYNIOS-224
 */
- (void)loadIssueWithModel:(IssueModel*)issueModel;
/** Shows a pre-loaded catalog. */
- (void)showCatalog:(CatalogModel*)catalog;
/** Shows the catalog screen on a specific page. */
- (void)inCurrentCatalogOpenPage:(NSInteger)index;
/** Show the catalog screen on a specific page that uses the given model. */
- (void)inCurrentCatalogOpenPageWithModel:(PageModel*)page;

//#pragma mark - Web Operations
//
//- (void)visitURL:(NSURLRequest*)req;
//- (void)visitPageWithHTML:(NSString*)html;


#pragma mark - Getters
- (NSArray*)allControllers;

#pragma mark - Layout

- (CGRect)frameForToolbar;

@end
