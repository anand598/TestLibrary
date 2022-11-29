//
//  FIRTrackProxy.h
//  Pods
//
//  Created by Schell Scivally on 3/25/13, updated by Rijul Gupta on 1/17/21.

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/TrackingResponseModel.h>
#import <SyndecaSDK/TrackingEventModel.h>
#import <SyndecaSDK/VideoModel.h>

/** A TrackingConclusion is the result of sending one TrackingEventModel to the server to be saved.
 This class is used in testing.
 */
@interface FIRTrackingConclusion : NSObject
@property (readwrite) TrackingEventModel* event;
@property (readwrite) TrackingResponseModel* response;

- (BOOL)wasSaved;
- (NSString*)name;
- (NSString*)detail;
@end

/**
 The FIRTrackProxy handles sending and maintaining batched tracking requests.
 In order to simplify the tracking methods themselves we must keep an up to date
 reference to the current models being viewed by the user. This means setting catalogModel, pageModels,
 elementModel, productModel and shareSite whenever the user views or accesses any screens or presentations
 related to those models.
 
 ## Discussion
 In the future it may be a good idea to simplify the specific tracking calls to take
 those models as parameters, then hold references to them internally instead of setting them explicitly before
 their associated tracking calls. For example:
 
     - (void)trackViewCatalog;
     - (void)trackViewPage;
     - (void)trackTapElement;
     - (void)trackViewProduct;
 
 could be updated to:
 
     - (void)trackViewCatalog:(CatalogModel*)catalog;
     - (void)trackViewPages:(NSArray<<PageModel*>*)pages;
     - (void)trackTapElement:(ElementModel*)element;
     - (void)trackViewProduct:(ProductModel*)product;
 
 and then references to the specific models can be updated in the implementation of those methods, and lastly those models'
 property declarations can be privatized. This would require an update of all client apps.
 */
@interface FIRTrackProxy : NSObject

#pragma mark - Models Needed For Tracking
/** @name Bookkeeping */

/** The model of the current catalog being displayed. */
@property (readwrite) CatalogModel* catalogModel;
/** The models of the current catalog pages being displayed. This array should have a length of one when viewed on
 a phone or in portrait on a pad, and two when viewed in landscape on a pad.*/
@property (readwrite) NSArray* pageModels;
/** The model of the last on-page element that was tapped or selected. */
@property (readwrite) ElementModel* elementModel;
/** The model of the current product being displayed. */
@property (readwrite) ProductGroupModel* productModel;
/** The name of the last site shared to. */
@property (readwrite) NSString* shareSite;

/** @brief The tracking interval. The number of seconds elapsed between batch
 tracking calls. */
@property (readwrite) NSUInteger interval;
/** @brief Whether or not the tracking proxy is waiting for the interval to
 clear. */
@property (readwrite) BOOL awaitingInterval;

#pragma mark - Tracking Events
/** @name Tracking Events */

/** @brief Tracks an app open event. */
- (void)trackAppOpen;
/** @brief Tracks an app close event. */
- (void)trackAppClose;
/** @brief Tracks the user tapping a navigation item in the tab bar.
 @param item The name of the nav item tapped.
 */
- (void)trackNavTap:(NSString*)item;
/** @brief Tracks an event of the user viewing the guide screen. */
- (void)trackViewGuide;
/** @brief Tracks an event of the user viewing the catalog screen.
 @warning Before calling this method you must set catalogModel. */
- (void)trackViewCatalog;
/** @brief Tracks an event of the user viewing a page or spread.
 @warning Before calling this method you must set pageModels. */
- (void)trackViewPage;
/** @brief Tracks an event of the user viewing the shopping cart screen. */
- (void)trackViewCart;
/** @brief Tracks an event of the user viewing the wishlist screen. */
- (void)trackViewWishlist;
/** @brief Tracks an event of the user viewing the product details screen.
 @warning Before calling this method you must set productModel. */
- (void)trackViewProduct;
/** @brief Tracks an event of the user viewing the scan+shop screen. */
- (void)trackViewScanner;
/** @brief Tracks an event of the user viewing the "more apps" screen. */
- (void)trackViewMore;
/** @brief Tracks an event of the user viewing a video. */
- (void)trackViewVideo:(VideoModel*)v;
/** @brief Tracks the event of a video starting. */
- (void)trackStartVideo:(VideoModel*)v;
/** @brief Tracks the event of a video stopping. */
- (void)trackStopVideo:(VideoModel*)v;
/** @brief Tracks the event of a user attempting a scan+shop scan. */
- (void)trackScanAttempt;
/** @brief Tracks the event of a user receiving a scan+shop error. */
- (void)trackScanError;
/** @brief Tracks the event of a user receiving a scan+shop success.
 @param c The model of the catalog in which the page whas found.
 @param p The model of the page that was scanned.*/
- (void)trackScanSuccess:(CatalogModel*)c withPage:(PageModel*)p;
/** @brief Tracks an opening of the table of contents. */
- (void)trackTOCShow;
/** @brief Tracks a closing of the table of contents. */
- (void)trackTOCClose;
/** @brief Tracks a selection in the table of contents. */
- (void)trackTOCSelection;

/** @brief Tracks an on-page element being tapped.
 @warning Before calling this method be sure to set elementModel. */
- (void)trackTapElement;
- (void)trackLinkClick:(NSString *)url;
/** @brief Tracks a tap of the shop-now button in the product details.
 @warning Before calling this method be sure to set productModel. */
- (void)trackTapShopNow;

/** @brief Tracks a share of the the current page.
 @warning Before calling this method be sure to set pageModels. */
- (void)trackSharePage;
/** @brief Tracks a share of the the current spread.
 @warning Before calling this method be sure to set pageModels. */
- (void)trackShareSpread;
/** @brief Tracks a share of the the current product.
 @warning Before calling this method be sure to set productModel. */
- (void)trackShareProduct;

/** @brief Tracks a zoom event on the the current page.
 @warning Before calling this method be sure to set pageModels. */
- (void)trackPageZoom;
/** @brief Tracks a scan of the the current page. This is used internally, but exported none-the-less.
 @warning Before calling this method be sure to set pageModels. */
- (void)trackPageScan;

/** @brief Tracks an event of the user adding a product to the shopping cart.
 @param product The product added to the cart.
 */
- (void)trackAddCart:(id<HasID>)product;
/** @brief Tracks an event of the user adding a product to the wishlist.
 @param product The product added to the wishlist.
 */
- (void)trackAddWishListGroup:(id<HasID>)product;
/** @brief Tracks an event of the user adding a product to the wishlist.
 @param product The product added to the wishlist.
 */
- (void)trackAddWishlist:(id<HasID>)product;
/** @brief Tracks an event of the user removing a product from the wishlist.
 @param productModelOrElement The removed product.
 */
- (void)trackRemoveFromWishlist:(id<HasID>)productModelOrElement;

/** @brief Tracks an event of the user exporting their cart to a check-out site.
 @param cart The exported cart model.
 */
- (void)trackExportCart:(ShoppingCart*)cart;
/** @brief Tracks an event of the user exporting their wishlist to a check-out site or email.
 @param list The exported cart model.
 */
- (void)trackExportWishlist:(ShoppingCart*)list;

/** @brief Tracks an event of the use of the search bar to search for products or pages.
 @param s The string used in the search.
 */
- (void)trackSearchPhrase:(NSString*)s;
/** @brief Tracks an event of the API returning search results.
 @param a The search results.
 */
- (void)trackSearchResults:(NSArray*)a;

#pragma mark - Class Getters/Setters
/** The shared proxy. */
+ (FIRTrackProxy*)defaultProxy;
/** An alias for defaultProxy. */
+ (FIRTrackProxy*)sharedProxy;
/** Sets the default proxy. Use this to override the default interval of 30secs. */
+ (void)setDefaultProxy:(FIRTrackProxy*)proxy;
/** Creates a new tracking proxy that sends batched tracking events every 'interval' seconds. */
- (id)initWithInterval:(NSTimeInterval)interval;

#pragma mark - Nitty Gritty Tracking
/** The current cache of tracking events. */
@property (readwrite) NSArray* cache;
/** A cache for use when tracking is paused. */
@property (readwrite) NSArray* pausedCache;
/** The signal that controls when tracking events get sent to the server. */
@property (readwrite) RACSignal* sendEventsSignal;
/** The signal of responses from the server. */
@property (readwrite) RACSignal* receiveResponseSignal;
/** The last tracking response. */
@property (readwrite) TrackingResponseModel* lastResponse;

/** @brief Adds a TrackingEventModel to the current batch.
    @param eventModel The TrackingEventModel to add to the current batch.
    @return void
 */
- (void)addEvent:(TrackingEventModel*)eventModel;
/** @brief Sends all batched events. If the network is not available or an error occurs, any err'd
           events will be saved and tried at the next interval.
 */
- (void)sendEvents;
/** @brief Returns a signal that sends a batch of tracking events to be stored.
    @param cache The batch of tracking events to store.
    @return A signal that performs the storage request and sends a
            TrackingResponse model on success.
 */
- (RACSignal*)sendTrackingBatch:(NSArray*)cache;

#pragma mark - Helpers for Testing
/** @brief Starts collecting tracking responses. */
- (void)collectResponses;
/** @brief Stops saving tracking responses. */
- (void)clearResponses;
/** @brief Returns all tracking responses since calling collectResponses. */
- (NSArray*)getResponses;


@end
