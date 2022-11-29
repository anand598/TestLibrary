//
//  TrackingEventModel.h
//  SyndecaSDK
//
//  Created by Schell Scivally on 3/25/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/PageModel.h>
#import <SyndecaSDK/ElementModel.h>
//#import "ProductModel.h"
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/ElementLinkModel.h>
#import <SyndecaSDK/ShoppingCart.h>

@interface TrackingEventModel : NSObject

@property (readwrite) NSTimeInterval timestamp;
@property (readwrite) NSString* event;
@property (readwrite) NSString* path;
@property (readwrite) NSDictionary* data;
/** Extra info that can be used by client specific proxies. */
@property (readwrite) NSDictionary* extras;

- (id)initWithEvent:(NSString*)event
               path:(NSString*)path
            andData:(NSDictionary*)data;

#pragma mark - Event Constructors
#pragma mark App
+ (TrackingEventModel*)trackEvent:(NSString*)event
                     withGuideKey:(NSString*)key
                          andData:(NSDictionary*)data;

#pragma mark Catalog
+ (TrackingEventModel*)trackEvent:(NSString*)event
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data;

+ (TrackingEventModel*)viewCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)closeCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)showTOCInCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)closeTOCInCatalog:(CatalogModel*)catalogModel;

#pragma mark Page

+ (TrackingEventModel*)trackEvent:(NSString*)event
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data;

+ (TrackingEventModel*)viewPage:(PageModel*)pageModel
                      ofCatalog:(CatalogModel*)catalegModel;

+ (TrackingEventModel*)viewSpreadWithLeftPage:(PageModel*)leftPage
                                    ofCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)sharePage:(PageModel*)pageModel
                       inCatalog:(CatalogModel*)catalogModel
                          onSite:(NSString*)siteKey;

+ (TrackingEventModel*)shareSpreadWithLeftPage:(PageModel*)pageModel
                                     inCatalog:(CatalogModel*)catalogModel
                                        onSite:(NSString*)siteKey;

+ (TrackingEventModel*)selectPage:(PageModel*)pageModel
                   inTOCOfCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)zoomPage:(PageModel*)pageModel
                      inCatalog:(CatalogModel*)catalogModel;

#pragma mark Element
+ (TrackingEventModel*)tapElement:(ElementModel*)elementModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)visitElementLink:(ElementLinkModel*)elementLinkModel
                                 onPage:(PageModel*)pageModel
                              inCatalog:(CatalogModel*)catalogModel;

#pragma mark Product
+ (TrackingEventModel*)trackEvent:(NSString*)event
                      withElement:(ElementModel*)elementModel
                       andProduct:(ProductGroupModel*)productModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data;

+ (TrackingEventModel*)tapProduct:(ProductGroupModel*)productModel
                        ofElement:(ElementModel*)elementModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel;

+ (TrackingEventModel*)shareProduct:(ProductGroupModel*)productModel
                          ofElement:(ElementModel*)elementModel
                             onPage:(PageModel*)pageModel
                          inCatalog:(CatalogModel*)catalogModel
                             onSite:(NSString*)siteKey;

+ (TrackingEventModel*)tapMediaOfProduct:(ProductGroupModel*)productModel
                                  onPage:(PageModel*)pageModel
                               inCatalog:(CatalogModel*)catalogModel;

#pragma mark - Cart / Add to Bag
+ (TrackingEventModel*)addToCartElement:(ElementModel*)e
                                 onPage:(PageModel*)p
                              inCatalog:(CatalogModel*)c;

+ (TrackingEventModel*)exportCart:(ShoppingCart*)s inCatalog:(CatalogModel*)c;

#pragma mark - Wishlist
+ (TrackingEventModel*)addToWishlistElement:(ElementModel*)e
                                     onPage:(PageModel*)p
                                  inCatalog:(CatalogModel*)c;

+ (TrackingEventModel*)removeFromWishlistElement:(ElementModel*)e
                                          onPage:(PageModel*)p
                                       inCatalog:(CatalogModel*)c;

+ (TrackingEventModel*)exportWishlist:(ShoppingCart*)s inCatalog:(CatalogModel*)c;

#pragma mark - Other Navigation
+ (TrackingEventModel*)viewCartInCatalog:(CatalogModel*)c;
+ (TrackingEventModel*)viewWishlistInCatalog:(CatalogModel*)c;
+ (TrackingEventModel*)viewScan;
+ (TrackingEventModel*)viewMore;

#pragma mark - Helpers
   
- (NSDictionary*)toDictionary;

@end
