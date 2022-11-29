//
//  SyndecaServiceFacade.h
//  CocoaViewer
//
//  Created by Schell Scivally on 11/15/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaConfig.h>
#import <SyndecaSDK/SyndecaRequest.h>
#import <SyndecaSDK/TrackingEventModel.h>
#import <SyndecaSDK/DependencyInjection.h>


/** The interface between the Syndeca iOS SDK and the outside world.
 An agent that needs models from a service will create a request using one
 of the factory methods exposed by SyndecaService. The SyndecaRequest is a
 a handle which will contain the state of the request and eventually the 
 result of the request.
 
 All apps use FetchProxy (which in turn uses this class to create SyndecaRequests) 
 for fetching and mapping the results of a SyndecaRequest. The only updating 
 anyone should have to do here is possibly adding new request methods as the API 
 grows.
 */
@interface SyndecaService : NSObject <DependencyInjection>

#pragma mark - Using or Setting the Shared Service
+ (SyndecaService*)sharedService;
+ (void)setSharedService:(SyndecaService*)service;

#pragma mark - Configuring the Service
/** Use this property to configure the service. */
@property (readwrite) SyndecaConfig* config;

#pragma mark - Request Methods
/** A guide resource. */
- (SyndecaRequest*)guideRequestForDelegate:(id<SyndecaRequestDelegate>)delegate;
/** Use a head request when the last time the guide model was changed. */
- (SyndecaRequest*)guideHeadRequestForDelegate:(id<SyndecaRequestDelegate>)delegate;
/** A catalog resource. */
- (SyndecaRequest*)catalogRequestWithId:(NSString*)ID
                            andBuildNum:(NSString*)buildNum
                            forDelegate:(id<SyndecaRequestDelegate>)delegate;
/** A product resource by page range. */
- (SyndecaRequest*)productRequestForPageWithNumber:(NSUInteger)from
                                  toPageWithNumber:(NSUInteger)to
                                     withCatalogId:(NSString*)catalogId
                                       andBuildNum:(NSString*)buildNum
                                       forDelegate:(id<SyndecaRequestDelegate>)delegate;

/** A tracking resource request for the given tracking events. */
- (SyndecaRequest*)trackingRequestWithEvents:(NSArray<TrackingEventModel*>*)events;
/** Returns a NSURL for sharing a page with the given site key and share key. */
- (NSURL*)sharalityURLForSite:(NSString*)siteKey andShare:(NSString*)shareKey;
/** A request for the email url related to the share. */
- (SyndecaRequest*)sharalityEmailURLRequestForShareKey:(NSString*)shareKey;
/** A request to search for some text in a catalog. */
//- (SyndecaRequest*)searchRequestWithText:(NSString*)text andCatalogId:(NSString*)ID;

/** A request to search for some text across all catalogs in the guide*/
- (SyndecaRequest*)crossCatalogSearchRequestWithText:(NSString*)text;

    
/** A request to search for some text in a catalog. Includes Build number */
- (SyndecaRequest*)searchRequestWithText:(NSString*)text andCatalogId:(NSString*)ID andBuildNum:(NSString*)buildNum;
/** A request to search for a product by barcode. */
- (SyndecaRequest*)productRequestWithBarcode:(NSString*)code;

@end
