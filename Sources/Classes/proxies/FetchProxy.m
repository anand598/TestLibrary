//
//  Retrievers.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 2/22/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <ReactiveCocoa/RACEXTScope.h>
#import "AFNetworkReachabilityManager.h"
#import "FetchProxy.h"
#import "OfflineProxy.h"
#import "FIRTrackProxy.h"
#import "SyndecaService.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "SearchModel.h"

#ifndef USE_PRODUCT_CACHE
#define USE_PRODUCT_CACHE YES
#endif

@implementation FetchProxyHelper
@end

@implementation FetchProxy

#pragma mark - Caches

static OfflineCatalog* __offlineCatalog = nil;

static NSMutableDictionary* __productModelCache = nil;
+ (NSMutableDictionary*)productModelCache {
    if (!__productModelCache) {
        __productModelCache = [NSMutableDictionary dictionary];
    }
    return __productModelCache;
}

+ (void)clearProductModelCache {
    __productModelCache = nil;
}

static BOOL __isOffline = NO;
+ (BOOL)isOffline {
    return __isOffline;
}

+ (void)setIsOffline:(BOOL)is {
    __isOffline = is;
}

#pragma mark - Getters

static FetchProxyHelper* __helper = nil;
+ (FetchProxyHelper*)helper {
    if (!__helper) {
        __helper = [[FetchProxyHelper alloc] init];
    }
    return __helper;
}

+ (void)withHelper:(void(^)(FetchProxyHelper* h))block {
    if (__helper) {
        block(__helper);
    }
}

#pragma mark - Post Mapping

static NSMutableDictionary* __postMappingBlocks = nil;
+ (NSMutableDictionary*)postMappingBlocks {
    if (!__postMappingBlocks) {
        __postMappingBlocks = [NSMutableDictionary dictionary];
    }
    return __postMappingBlocks;
}

+ (void)usePostMappingBlock:(PostMappingBlock)mappingBlock
      afterRequestsWithType:(SyndecaRequestType)requestType {
    NSString* key = [NSString stringWithFormat:@"%i",requestType];
    [[self postMappingBlocks] setValue:[mappingBlock copy] forKey:key];
}

+ (void)clearPostMappingBlocks {
    __postMappingBlocks = nil;
}


#pragma mark - API Requests
+ (RACSignal*)fetchRequest:(SyndecaRequest *)request withMappingBlock:(SyndecaResultMappingBlock)mapper {
    // This signal will start a new request whenever this method is called.
    RACSignal* fetchSignal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [request startWithCompleteBlock:^(SyndecaRequest* request) {
            // The model mapper is injected into this signal from the caller
            // so it can visit here and transform the request response into some
            // typed model that the caller can use instead of some free-form
            // JSON that has to be conditionally checked before accessing.
//            NSDictionary* headers = [request.operation.operation.tasks allHeaderFields];
            id mappedResult = mapper(request);
            if (!mappedResult) {
                [subscriber sendError:[NSError errorWithDomain:@"Result data could not be mapped."
                                                          code:0
                                                      userInfo:@{@"request":request}]];
                return;
            }
            // Find whether or not there is a post mapping block for this type
            // of request (used for testing).
            NSString* key = [NSString stringWithFormat:@"%i",request.type];
            id postMappingBlock = [[self postMappingBlocks] valueForKey:key];
            if (postMappingBlock) {
                // Process the result one more time.
                PostMappingBlock block = (PostMappingBlock)postMappingBlock;
                mappedResult = block(mappedResult);
            }
            
            [subscriber sendNext:mappedResult];
            [subscriber sendCompleted];
            
            if ([mappedResult isKindOfClass:[GuideModel class]]) {
                [FetchProxy withHelper:^(FetchProxyHelper *h) {
                    h.guide = mappedResult;
                }];
            }
            if ([mappedResult isKindOfClass:[CatalogModel class]]) {
                [FetchProxy withHelper:^(FetchProxyHelper *h) {
                    h.catalog = mappedResult;
                }];
            }
        } andError:^(NSError* error) {
            [subscriber sendError:error];
        }];
        // Cancels the request when this subscription is disposed.
        return [RACDisposable disposableWithBlock:^{
            [request cancel];
        }];
    }];
    return fetchSignal;
}

//+ (RACSignal*)fetchRequest:(SyndecaRequest *)request withMappingBlock:(SyndecaResultMappingBlock)mapper {
//    // This signal will start a new request whenever this method is called.
//    RACSignal* fetchSignal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
//        [request startWithCompleteBlock:^(SyndecaRequest* request) {
//            // The model mapper is injected into this signal from the caller
//            // so it can visit here and transform the request response into some
//            // typed model that the caller can use instead of some free-form
//            // JSON that has to be conditionally checked before accessing.
//            NSDictionary* headers = [request.operation.operation.response allHeaderFields];
//            id mappedResult = mapper(request);
//            if (!mappedResult) {
//                [subscriber sendError:[NSError errorWithDomain:@"Result data could not be mapped."
//                                                          code:0
//                                                      userInfo:@{@"request":request}]];
//                return;
//            }
//            // Find whether or not there is a post mapping block for this type
//            // of request (used for testing).
//            NSString* key = [NSString stringWithFormat:@"%i",request.type];
//            id postMappingBlock = [[self postMappingBlocks] valueForKey:key];
//            if (postMappingBlock) {
//                // Process the result one more time.
//                PostMappingBlock block = (PostMappingBlock)postMappingBlock;
//                mappedResult = block(mappedResult);
//            }
//
//            [subscriber sendNext:mappedResult];
//            [subscriber sendCompleted];
//
//            if ([mappedResult isKindOfClass:[GuideModel class]]) {
//                [FetchProxy withHelper:^(FetchProxyHelper *h) {
//                    h.guide = mappedResult;
//                }];
//            }
//            if ([mappedResult isKindOfClass:[CatalogModel class]]) {
//                [FetchProxy withHelper:^(FetchProxyHelper *h) {
//                    h.catalog = mappedResult;
//                }];
//            }
//        } andError:^(NSError* error) {
//            [subscriber sendError:error];
//        }];
//        // Cancels the request when this subscription is disposed.
//        return [RACDisposable disposableWithBlock:^{
//            [request cancel];
//        }];
//    }];
//    return fetchSignal;
//}

/* Looks for a guide model header to see if there is anything new. This allows us to cache information and only call for a real guide update when necessary */
+ (RACSignal*)fetchGuideHeader {
    NSHTTPURLResponse *response;
    SyndecaRequest* request = [[SyndecaService sharedService] guideHeadRequestForDelegate:nil];
    
    return [NSURLConnection rac_sendAsynchronousRequest:request];
}

/*Called by the GuideViewController - returns a RACSignal that contains a Guide Model */
+ (RACSignal*)fetchGuideModel {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // SYN-339
        // Scan + Shop - Allow archived catalogs to be "Scan and Shopped"
        // Reset the archive flag.
        [SyndecaService sharedService].config.isArchive = NO;
        SyndecaRequest* request = [[SyndecaService sharedService] guideRequestForDelegate:nil];
        [[self fetchRequest:request withMappingBlock:^id(SyndecaRequest *request) {
            [FetchProxy setIsOffline:NO];
            // This block uses the GuideModelMapper to map the response into a guideModel.
            GuideModel* guideModel = [[[GuideModel DIClass] alloc] initWithInfo:[request result]];
            return guideModel;
        }] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            // Try offline
            NSLog(@"Received error from guide request: %@\nTrying offline.",error);
            [FetchProxy setIsOffline:YES];
            GuideModel* guide = [OfflineProxy sharedProxy].offlineGuide;
            [subscriber sendNext:guide];
            [subscriber sendCompleted];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

/* Used to instantiate a catalog model from an issue model. The guide model contains issue models, but we need catalog models to instantiate CatalogViewController. Use this method to obtain a catalog model from an issue model whenever necessary */
+ (RACSignal*)fetchCatalogModelUsingIssueModel:(IssueModel*)issueModel {
    if ([FetchProxy isOffline]) {
        // Return the shizz off the disc.
        __offlineCatalog = [[OfflineProxy sharedProxy] offlineCatalogWithIssueID:issueModel.ID];
        if (__offlineCatalog) {
            return [RACSignal return:__offlineCatalog.catalogModel];
        } else {
            return [RACSignal error:[NSError errorWithDomain:@"This catalog is not downloaded." code:0 userInfo:nil]];
        }
    }
    __offlineCatalog = nil;
    
    SyndecaRequest* request = [[SyndecaService sharedService] catalogRequestWithId:issueModel.ID
                                                                             andBuildNum:issueModel.buildNum
                                                                             forDelegate:nil];
    
    return [self fetchRequest:request withMappingBlock:^id(SyndecaRequest *request) {
        CatalogModel* catalogModel = [[[CatalogModel DIClass] alloc] initWithInfo:request.result];
        catalogModel.guide = issueModel.guide;
        return catalogModel;
    }];
}

+ (RACSignal*)fetchProductFromBarcode:(NSString*)barcode {
    SyndecaRequest* request = [[SyndecaService sharedService] productRequestWithBarcode:barcode];
    return [self fetchRequest:request withMappingBlock:^id(SyndecaRequest *request) {
        ProductGroupModel* product = [[[ProductGroupModel DIClass] alloc] initWithInfo:request.result];
        return product;
    }];
}

+ (RACSignal*)fetchSharalityEmailURLForShareKey:(NSString*)shareKey {
    SyndecaRequest* request = [[SyndecaService sharedService] sharalityEmailURLRequestForShareKey:shareKey];
    return [self fetchRequest:request withMappingBlock:^id(SyndecaRequest *request) {
        NSDictionary* result = request.result;
        NSString* urlString = [result stringByKey:@"Url"];
        return [NSURL URLWithString:urlString];
    }];
}

#pragma mark - Products
/* Returns every product on every page sorted by the page number. This will return multiple products if they are on more than one page. Used in PublicationController and SearchViewController - see implementation for filtering method */
+ (RACSignal*)fetchProductsInPageModelsSortedByPage:(NSArray *)pageModels fromCatalogModel:(CatalogModel *)catalogModel {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //We fetch all products for all pages, returns an array of all products
        [[FetchProxy
          fetchProductsInPageModels:pageModels
          fromCatalogModel:catalogModel]
         subscribeNext:^(NSArray* products) {
             
             // Create an array for each page.
             NSMutableArray* productsByPage = [NSMutableArray array];
             
             //Loop through each page in the original function call
             for (PageModel* page in [pageModels objectEnumerator]) {
                 NSMutableArray* productsOnPage = [NSMutableArray array];
                 
                 // Loop through all products for all pages and selectively add if they are located on this page
                 for (ProductGroupModel* product in products) {
                     BOOL shouldAddProduct = false;
                     // Grab all the ids for this product(group).
                     NSArray<NSString*>* ids = @[];
                     if (product.ID != nil) {
                         ids = [ids arrayByAddingObject:product.ID];
                     }
                     for (ProductEntityModel* entity in product.entities) {
                         if (entity.ID != nil) {
                             ids = [ids arrayByAddingObject:entity.ID];
                         }
                     }

                     
                     //Loop through each product on this page and see if matches this product
                     for (ElementModel* element in page.elementModels) {
                         // Check to see if the group's id or any entity id matches the element's product id.
                         NSString* onPageVariantId = element.onPageVariantId;
                         if ([ids containsObject:element.productID] || [ids containsObject:element.ID]) {
                             // This product is shown on this page and has some elements mapped for it.
                             product.associatedElements = [product.associatedElements arrayByAddingObject:element];
                             shouldAddProduct = true;
                             
                             for(ProductEntityModel* entModel in product.entities){
                                 if([entModel.ID isEqualToString:onPageVariantId]){
                                     product.onPageVariant = onPageVariantId;
                                 }
                             }
                            
                         } else {
                         }
                     } // finish page element models loop
                     
                     if(shouldAddProduct == true) {
                         // Add the product to the page.
                         [productsOnPage addObject:product];
                     } else {
                         NSLog(@"%s filtering product %@ because it has no associated element on page %lu.",__func__,product.name,(unsigned long)page.number);
                     }
                 } // finish all products loop
                 
                 // Add this page to our array of pages
                 [productsByPage addObject:[NSArray arrayWithArray:productsOnPage]];
             }// finish all pages loop
             
             [subscriber sendNext:[NSArray arrayWithArray:productsByPage]];
             [subscriber sendCompleted];
         } error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return [RACDisposable disposableWithBlock:^{}];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

/* Fetches all products in the passed page models for the given catalog model. The catalog model must be supplied for the api call.*/
+ (RACSignal*)fetchProductsInPageModels:(NSArray *)pageModels fromCatalogModel:(CatalogModel*)catalogModel {
    NSUInteger from = NSUIntegerMax;
    NSUInteger to = 0;
    for (PageModel* pageModel in pageModels) {
        from = pageModel.number < from ? pageModel.number : from;
        to = pageModel.number > to ? pageModel.number : to;
    }
    
    // Check if we need to fetch products.
    NSArray* elementModels = @[];
    for (PageModel* pageModel in pageModels) {
        elementModels = [elementModels arrayByAddingObjectsFromArray:pageModel.elementModels];
    }
    if ([elementModels count] == 0) {
        // There are no products to download so send back an empty result.
        return [[RACSignal return:@[]] deliverOn:[RACScheduler mainThreadScheduler]];
    }
    
    // Get the products.
    return [[FetchProxy fetchProductsFromPage:from
                                       toPage:to
                               inCatalogModel:catalogModel]
            deliverOn:[RACScheduler mainThreadScheduler]];
}

/* Fetches all products in between certain pages - often used in tablet view to get all products for both pages in view */
+ (RACSignal*)fetchProductsFromPage:(NSUInteger)from toPage:(NSUInteger)to inCatalogModel:(CatalogModel*)catalogModel {
    // If we're viewing an offline catalog just go straight for that.
    if ([FetchProxy isOffline]) {
        if (!__offlineCatalog) {
            __offlineCatalog = [[OfflineProxy sharedProxy] offlineCatalogWithIssueID:catalogModel.ID];
        }
        if (__offlineCatalog) {
            NSArray* products = @[];
            NSUInteger f = from - 1; NSUInteger t = to - 1;
            NSRange r; r.location = f; r.length = t - f + 1;
            NSIndexSet* i = [NSIndexSet indexSetWithIndexesInRange:r];
            NSArray* pages = [catalogModel.pageModels objectsAtIndexes:i];
            
            for (PageModel* page in pages) {
                for (ElementModel* el in page.elementModels) {
                    for (ProductGroupModel* p in __offlineCatalog.products) {
                        if ([p.ID isEqualToString:el.productID]) {
                            if([p.entities count] > 0){
                                // This product is shown on this page and has some elements mapped for it.
                                products = [products arrayByAddingObject:p];
                            }
                            else{
                                NSLog(@"Product had not entities");
                            }
                            
                        }
                    }
                }
            }
            return [RACSignal return:products];
        } else {
            return [RACSignal error:[NSError errorWithDomain:@"This catalog has not been downloaded." code:666 userInfo:nil]];
        }
    }
    
    __offlineCatalog = nil;
    return [self fetchProductsFromPage:from
                                toPage:to
                        inCatalogModel:catalogModel
                             fromCache:self.productModelCache];
}

+ (RACSignal*)fetchProductsFromPage:(NSUInteger)from toPage:(NSUInteger)to inCatalogModel:(CatalogModel*)catalogModel fromCache:(NSMutableDictionary*)cache {
    // This signal will kick off a product request when intially subscribed to.
    RACSignal* fetchProducts = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        SyndecaRequest* request = [[SyndecaService sharedService]
                                   productRequestForPageWithNumber:from
                                   toPageWithNumber:to
                                   withCatalogId:catalogModel.ID
                                   andBuildNum:catalogModel.buildNum
                                   forDelegate:nil];
        // Get the product models out of the cache or make a new
        // request.
        if ([[cache allKeys] containsObject:request.resource]
            && [[cache valueForKey:request.resource] respondsToSelector:@selector(indexOfObject:)]) {
            NSArray* productModels = [cache arrayByKey:request.resource];
            [subscriber sendNext:productModels];
            [subscriber sendCompleted];
        } else {
            [cache setValue:request forKey:request.resource];
            [request startWithCompleteBlock:^(SyndecaRequest* request) {
                // ProductModel-ify the responses...
                NSArray* rawProducts = [request result];
                NSArray* productModels = [[rawProducts.rac_sequence map:^ProductGroupModel*(NSDictionary* rawProduct) {
                    

                    ProductGroupModel* productModel = [[[ProductGroupModel DIClass] alloc] initWithInfo:rawProduct];
                    productModel.catalog = catalogModel;
                    return productModel;
                    
                    
                }] array];
                // Update the cache with the new data.
                if (USE_PRODUCT_CACHE) {
                    [cache setValue:productModels forKey:request.resource];
                }
                [subscriber sendNext:productModels];
                [subscriber sendCompleted];
            } andError:^(NSError* error) {
                [subscriber sendError:error];
            }];
        }
        return [RACDisposable disposableWithBlock:^{
            [request cancel];
        }];
    }];
    // Ensures that we only ever start one request to this signal instance. The
    // request will only be kicked off on the first subscription, but all
    // subscribers will get the same results.
    return [fetchProducts replayLazily];
}

#pragma mark - Tracking

+ (RACSignal*)fetchTrackingResponseForEvents:(NSArray*)events {
    SyndecaRequest* request = [[SyndecaService sharedService] trackingRequestWithEvents:events];
    return [self fetchRequest:request withMappingBlock:^id(SyndecaRequest *request) {
        return request.result;
    }];
}

#pragma mark - Searching

/* Returns a RACSignal that sends an arrap of SearchModel items found within the current guide
 that match the input search text. */
+ (RACSignal*)fetchSearchResultsForText:(NSString*)text inGuide:(GuideModel*) guide {
    SyndecaRequest* r = [[SyndecaService sharedService] crossCatalogSearchRequestWithText:text];
    
    return [FetchProxy fetchRequest:r withMappingBlock:^id(SyndecaRequest *request) {
        // There is no search mapper, so this block will do.
        NSArray* items = @[];
        NSDictionary* info = (NSDictionary*)request.result;
        NSDictionary* hits = [info infoByKey:@"hits"];
        NSArray* hits2 = [hits arrayByKey:@"hits"];
        if (hits2) {
            for (NSDictionary* hit in hits2) {
                SearchModel* item = [[SearchModel alloc] initWithInfo:hit fromGuide:guide];
                items = [items arrayByAddingObject:item];
            }
        }
        return items;
    }];
}

/*Returns all pages that match a search term within a catalog model. Used if we want to return catalog pages in search view controller */
+ (RACSignal*)fetchSearchResultsAsPageIdsForText:(NSString *)text inCatalogModel:(CatalogModel *)catalogModel {
    SyndecaRequest* r = [[SyndecaService sharedService]
                         searchRequestWithText:text andCatalogId:catalogModel.ID andBuildNum:catalogModel.buildNum];
    return [FetchProxy fetchRequest:r withMappingBlock:^id(SyndecaRequest *request) {
        // There is no search mapper, so this block will do.
        NSArray* ids = @[];
        NSDictionary* info = (NSDictionary*)request.result;
        NSDictionary* hits = [info infoByKey:@"hits"];
        NSArray* hits2 = [hits arrayByKey:@"hits"];
        if (hits2) {
            for (NSDictionary* hit in hits2) {
                NSDictionary* source = [hit infoByKey:@"_source"];
                NSString* pageID = [source stringByKey:@"page_id"];
                if (pageID) {
                    ids = [ids arrayByAddingObject:pageID];
                }
            }
        }
        return ids;
    }];
    
}

/* Returns all products that match a key search term within a catalog model - used in search view controller. Only works on one catalog at a time. */
+ (RACSignal*)fetchSearchResultsAsProductsForText:(NSString *)text inCatalogModel:(CatalogModel *)catalogModel{
    SyndecaRequest* r = [[SyndecaService sharedService]
                         
                         searchRequestWithText:text andCatalogId:catalogModel.ID andBuildNum:catalogModel.buildNum];
    
    return [FetchProxy fetchRequest:r withMappingBlock:^id(SyndecaRequest *request) {
        
        // There is no search mapper, so this block will do.
        NSArray* ids = @[];
        NSDictionary* info = (NSDictionary*)request.result;
        NSDictionary* hits = [info infoByKey:@"hits"];
        NSArray* hits2 = [hits arrayByKey:@"hits"];
        
        if (hits2) {
            for (NSDictionary* hit in hits2) {
                NSDictionary* source = [hit infoByKey:@"_source"];
                NSDictionary* bothIDsObject;
                NSArray* productIdArray = @[];
                NSString* pageID = [source stringByKey:@"page_id"];
                NSArray* productSource = [source infoByKey:@"products"];
                
                for(NSDictionary*productDict in productSource){
                    
                    NSNumber* productId = [productDict infoByKey:@"product_id"];
                    
                    NSString* productTitle = [productDict infoByKey:@"name"];
                    
                    NSString* productDesc = [productDict infoByKey:@"description"];
                    
                    if([productId stringValue]){
                        
                        if(([productTitle rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) || ([productDesc rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound)){
                            productIdArray = [productIdArray arrayByAddingObject:[productId stringValue]];
                        }
                    }
                }
                if (pageID && productIdArray) {
                    bothIDsObject = [[NSDictionary alloc] initWithObjects:@[productIdArray, pageID] forKeys:@[@"productIDs", @"pageID"]];
                }
                if(bothIDsObject){
                    ids = [ids arrayByAddingObject:bothIDsObject];
                }
            }
        }
        return ids;
    }];
}

/* Returns all products that match a search term across all catalogs with a specific Syndeca user key. Works to return all search results across all products. This method is spefically for the shop catalogs app */
+ (RACSignal*)fetchCrossCatalogSearchResultsAsProductsForTextInShopCatalogs:(NSString *)text{
    SyndecaRequest* r = [[SyndecaService sharedService] crossCatalogSearchRequestWithText:text];
    
    return [FetchProxy fetchRequest:r withMappingBlock:^id(SyndecaRequest *request) {
        
        // There is no search mapper, so this block will do.
        NSArray* ids = @[];
        NSDictionary* info = (NSDictionary*)request.result;
        NSDictionary* hits = [info infoByKey:@"hits"];
        NSArray* hits2 = [hits arrayByKey:@"hits"];
        
        if (hits2) {
            for (NSDictionary* hit in hits2) {
                NSDictionary* source = [hit infoByKey:@"_source"];
                NSDictionary* bothIDsObject;
                NSArray* productIdArray = @[];
                NSString* pageID = [source stringByKey:@"page_id"];
                NSArray* productSource = [source infoByKey:@"products"];
                
                for(NSDictionary*productDict in productSource){
                    
                    NSNumber* productId = [productDict infoByKey:@"product_id"];
                    
                    NSString* productTitle = [productDict infoByKey:@"name"];
                    
                    NSString* productDesc = [productDict infoByKey:@"description"];
                    
                    if([productId stringValue]){
                        
                        if(([productTitle rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) || ([productDesc rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound)){
                            productIdArray = [productIdArray arrayByAddingObject:[productId stringValue]];
                        }
                    }
                }
                if (pageID && productIdArray) {
                    bothIDsObject = [[NSDictionary alloc] initWithObjects:@[productIdArray, pageID] forKeys:@[@"productIDs", @"pageID"]];
                }
                if(bothIDsObject){
                    ids = [ids arrayByAddingObject:bothIDsObject];
                }
            }
        }
        return ids;
    }];
}

/* Returns all products that match a search term across all catalogs with a specific Syndeca user key. Works to return all search results across all products. */
+ (RACSignal*)fetchCrossCatalogSearchResultsAsProductsForText:(NSString *)text {
    SyndecaRequest* r = [[SyndecaService sharedService] crossCatalogSearchRequestWithText:text];
    
    return [FetchProxy fetchRequest:r withMappingBlock:^id(SyndecaRequest *request) {
        
        // There is no search mapper, so this block will do.
        NSArray* ids = @[];
        NSDictionary* info = (NSDictionary*)request.result;
        NSDictionary* hits = [info infoByKey:@"hits"];
        NSArray* hits2 = [hits arrayByKey:@"hits"];
        
        if (hits2) {
            for (NSDictionary* hit in hits2) {
                NSDictionary* source = [hit infoByKey:@"_source"];
                NSDictionary* bothIDsObject;
                NSArray* productIdArray = @[];
                NSString* pageID = [source stringByKey:@"page_id"];
                NSArray* productSource = [source infoByKey:@"products"];
                
                for(NSDictionary*productDict in productSource){
                    
                    NSNumber* productId = [productDict infoByKey:@"product_id"];
                    
                    NSString* productTitle = [productDict infoByKey:@"name"];
                    
                    NSString* productDesc = [productDict infoByKey:@"description"];
                    
                    if([productId stringValue]){
                        
                        if(([productTitle rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) || ([productDesc rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound)){
                            productIdArray = [productIdArray arrayByAddingObject:[productId stringValue]];
                        }
                    }
                }
                if (pageID && productIdArray) {
                    bothIDsObject = [[NSDictionary alloc] initWithObjects:@[productIdArray, pageID] forKeys:@[@"productIDs", @"pageID"]];
                }
                if(bothIDsObject){
                    ids = [ids arrayByAddingObject:bothIDsObject];
                }
            }
        }
        return ids;
    }];
}

@end
