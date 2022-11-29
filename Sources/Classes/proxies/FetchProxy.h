//
//  Retrievers.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 2/22/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/SyndecaRequest.h>
#import <SyndecaSDK/GuideModel.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/OfflineCatalog.h>

typedef id (^SyndecaResultMappingBlock) (SyndecaRequest* request);
typedef id (^PostMappingBlock) (id mappedObject);

/** A fetch proxy helper is used for automating certain tasks by allowing the
 programmer to create signals on its properties. These properties will be 
 updated on [FetchProxy helper] after each new fetch.
 */
@interface FetchProxyHelper : NSObject
@property GuideModel* guide;
@property CatalogModel* catalog;
@end

/** Used for fetching resources from the SyndecaAPI and CDN. Hopefully most of
 the method names here explain exactly what they are doing.
 
 The SyndecaSDK is config'd during app startup so it already knows which client's
 guide to fetch etc. Please see a client AppDelegate for details.
 
 FetchProxy works in tandem with offline proxy to serve cached data whenever
 possible.
 */
@interface FetchProxy : NSObject

#pragma mark - Getters (for automation)
+ (FetchProxyHelper*)helper;

#pragma mark - Modes
+ (BOOL)isOffline;
+ (void)setIsOffline:(BOOL)offline;

#pragma mark - SyndecaAPI
/** Our most general fetch.
 The other fetches do some finagling with the request and mapping block and then 
 proxy to this fetch.
 */
+ (RACSignal*)fetchRequest:(SyndecaRequest*)request
          withMappingBlock:(SyndecaResultMappingBlock)mapper;


+ (RACSignal*)fetchGuideHeader;
+ (RACSignal*)fetchGuideModel;
    
+ (RACSignal*)fetchCatalogModelUsingIssueModel:(IssueModel*)issueModel;
    
//+ (RACSignal*)fetchSharalitySiteList;
    
+ (RACSignal*)fetchSharalityEmailURLForShareKey:(NSString*)shareKey;

/** Fetches all products listed on the given pages.
 Sends to subscribers an array of all ProductModels in no particular order.
 */
+ (RACSignal*)fetchProductsInPageModels:(NSArray *)pageModels
                       fromCatalogModel:(CatalogModel*)catalogModel;

/** Fetches all products listed on the given pages.
 Sends to subscribers an array of arrays of products. Each array contains the
 products on the corresponding page. The arrays are sorted by page number, 
 increasing.
 */
+ (RACSignal*)fetchProductsInPageModelsSortedByPage:(NSArray *)pageModels fromCatalogModel:(CatalogModel *)catalogModel;
    
+ (RACSignal*)fetchTrackingResponseForEvents:(NSArray*)events;

+ (RACSignal*)fetchSearchResultsAsPageIdsForText:(NSString*)text
                         inCatalogModel:(CatalogModel*)catalogModel;

+ (RACSignal*)fetchSearchResultsForText:(NSString*)text inGuide:(GuideModel*)guide;

/** Fetches a product specified by barcode. */
+ (RACSignal*)fetchProductFromBarcode:(NSString*)barcode;

/** A search request to find all products associated with your guide key */
+ (RACSignal*)fetchCrossCatalogSearchResultsAsProductsForText:(NSString *)text;

/** A search request to find all products in a specific catalog */
+ (RACSignal*)fetchSearchResultsAsProductsForText:(NSString *)text inCatalogModel:(CatalogModel *)catalogModel;

#pragma mark - Caches
+ (NSMutableDictionary*)productModelCache;
+ (void)clearProductModelCache;

#pragma mark - Mapping Hooks (used for testing)
+ (void)usePostMappingBlock:(PostMappingBlock)mappingBlock
  afterRequestsWithType:(SyndecaRequestType)requestType;
+ (void)clearPostMappingBlocks;

@end
