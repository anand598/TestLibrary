//
//  FIRTrackProxy.m
//  Pods
//
//  Created by Rijul Gupta on 1/17/21.
//
//

#import "FIRTrackProxy.h"
#import "FetchProxy.h"
#import "SyndecaService.h"
#import "SyndecaConfig.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <FirebaseAnalytics/FIRAnalytics.h>

#if DEBUG
#define INTERVAL 1
#elif BETA
#define INTERVAL 1
#else
#define INTERVAL 30
#endif

#define EVENT_FILTER_INTERVAL 1

@implementation FIRTrackingConclusion

- (BOOL)wasSaved {
    return self.response.saved;
    return YES;
}

- (NSString*)name {
    return self.event.event;
}

- (NSString*)detail {
    NSString* data = @"";
    for (NSString* key in [self.event.data allKeys]) {
        data = [NSString stringWithFormat:@"%@ %@:%@",data,key,self.event.data[key]];
    }
    return [NSString stringWithFormat:@"%@\n%@",self.event.path, data];
}

@end

@interface FIRTrackProxy ()

@property (readwrite) NSArray* conclusions;
@property (readwrite) BOOL saveResponses;

@end

@implementation FIRTrackProxy

+ (NSString*)guideKey {
    return [SyndecaService sharedService].config.guideKey;
}

#pragma mark - Friendly stuff

- (void)trackViewVideo:(VideoModel*)v {
    NSString* path = [NSString stringWithFormat:@"/widget/%@",v.ID];
    TrackingEventModel* e = [[TrackingEventModel alloc]initWithEvent:@"view" path:path andData:nil];
    [self addEvent:e];
    
}

- (void)trackStartVideo:(VideoModel*)v {
    
    if (self.catalogModel && self.pageModels) {
        PageModel* leftPage = [self.pageModels firstObject];
        if (!leftPage) {
            return;
        }
        [FIRAnalytics logEventWithName:@"video_play"
                           parameters:@{
                               @"catalog_id": self.catalogModel.ID,
                               @"page_id": leftPage.ID,
                                        @"media_id": v.mediaId
                                        }];
        
    } else {
        [FIRAnalytics logEventWithName:@"video_play"
                           parameters:@{
                               @"catalog_id": @"",
                               @"page_id": @"",
                                        @"media_id": v.mediaId
                                        }];
    }
    
}

- (void)trackStopVideo:(VideoModel*)v {
    NSString* path = [NSString stringWithFormat:@"/widget/%@/media/%@",v.ID,v.mediaId];
    TrackingEventModel* e = [[TrackingEventModel alloc] initWithEvent:@"video-stop" path:path andData:nil];
    [self addEvent:e];
}

- (void)trackSearchPhrase:(NSString *)s {
    [FIRAnalytics logEventWithName:@"search"
                       parameters:@{
                                    @"search_term": s
                                    }];
}

- (void)trackSearchResults:(NSArray *)a {
    TrackingEventModel* e = [[TrackingEventModel alloc] initWithEvent:@"search-results"
                                                                 path:@""
                                                              andData:nil];
    e.extras = @{ @"results" : a};
    [self addEvent:e];
}

-(void)trackAddWishListGroup:(id<HasID>)productGroup{
    ProductGroupModel* p = (ProductGroupModel*)productGroup;
    PageModel* pg = [self findProductGroupPage:p];
    if (pg) {
       pg = [self.pageModels firstObject];
    }
    ElementModel* el = [self findProductGroupElement:p];

    TrackingEventModel* e = [TrackingEventModel
                             addToWishlistElement:el
                             onPage:pg
                             inCatalog:self.catalogModel];

    if(self.catalogModel){
        e.extras = @{ @"catalog" : self.catalogModel,
                      @"page" : pg,
                      @"product" : p
                      };
    }else{
        e.extras = @{ @"page" : pg,
                      @"product" : p
                      };
    }


    [self addEvent:e];
}

- (void)trackAddWishlist:(id<HasID>)product {
    ProductEntityModel* p = (ProductEntityModel*)product;
    PageModel* pg = [self findProductPage:p];
    if (!pg && p.parent) {
        return [self trackAddWishlist:p.parent];
    } else {
        pg = [self.pageModels firstObject];
    }

    ElementModel* el = [self findProductElement:p];

    TrackingEventModel* e = [TrackingEventModel
                             addToWishlistElement:el
                             onPage:pg
                             inCatalog:self.catalogModel];
    e.extras = @{ @"catalog" : self.catalogModel,
                  @"page" : pg,
                  @"product" : p
                  };
    [self addEvent:e];
}

- (ProductGroupModel*)getProductUsingThing:(id<HasID>)thing {
    if ([thing isKindOfClass:[ProductGroupModel class]]) {
        return (ProductGroupModel*)thing;
    }
    
    ProductGroupModel* p = [[ProductGroupModel alloc] initWithInfo:@{@"id" : thing.ID}];
    return p;
}

- (PageModel*)getPageUsing:(id<HasID>)thing {
    if ([thing isKindOfClass:[ProductGroupModel class]]) {
        ProductGroupModel* p = (ProductGroupModel*)thing;
        PageModel* pg = [self findProductPage:p];
        if (!pg) {
            pg = [self.pageModels firstObject];
        }
        return pg;
    }
    PageModel* pg = [[PageModel alloc] initWithInfo:@{@"id" : thing.ID}];
    return pg;
}

- (ElementModel*)getElementUsing:(id<HasID>)thing {
    ElementModel* el = [[ElementModel alloc] initWithInfo:@{@"id" : thing.ID}];
    
    if ([thing isKindOfClass:[ProductGroupModel class]]) {
        ProductGroupModel* p = (ProductGroupModel*)thing;
        PageModel* pg = [self findProductPage:p];
        if (!pg) {
            pg = [self.pageModels firstObject];
        }
        el = [self findProductElement:p];
    }
    
    return el;
}

- (void)trackRemoveFromWishlist:(id<HasID>)thing {
    ElementModel* el = [self getElementUsing:thing];
    PageModel* pg = [self getPageUsing:thing];
    ProductGroupModel* p = [self getProductUsingThing:thing];

    TrackingEventModel* e = [TrackingEventModel
                             removeFromWishlistElement:el
                             onPage:pg
                             inCatalog:self.catalogModel];
    e.extras = @{ @"catalog" : self.catalogModel,
                  @"page" : pg,
                  @"product" : p
                  };
    [self addEvent:e];
}

- (void)trackAddCart:(id<HasID>)thing {
    ElementModel* el = [self getElementUsing:thing];
    PageModel* pg = [self getPageUsing:thing];
    ProductGroupModel* p = [self getProductUsingThing:thing];

    TrackingEventModel* e = [TrackingEventModel
                             addToCartElement:el
                             onPage:pg
                             inCatalog:self.catalogModel];
    e.extras = @{ @"catalog" : self.catalogModel,
                  @"page" : pg,
                  @"product" : p
                  };
    [self addEvent:e];
}

//- (void)trackRemoveCart:(id<HasID>)thing {
//    ElementModel* el = [self getElementUsing:thing];
//    PageModel* pg = [self getPageUsing:thing];
//    ProductModel* p = [self getProductUsingThing:thing];
//
//    TrackingEventModel* e = [TrackingEventModel
//                             removeFromCartElement:el
//                             onPage:pg
//                             inCatalog:self.catalogModel];
//    e.extras = @{ @"catalog" : self.catalogModel,
//                  @"page" : pg,
//                  @"product" : p
//                  };
//    [self addEvent:e];
//}

- (void)trackExportCart:(ShoppingCart *)cart {
    TrackingEventModel* e = [TrackingEventModel exportCart:cart
                                                 inCatalog:self.catalogModel];
    e.extras = @{ @"cart" : cart };
    [self addEvent:e];
}

- (void)trackExportWishlist:(ShoppingCart *)list {
    TrackingEventModel* e = [TrackingEventModel exportWishlist:list
                                                     inCatalog:self.catalogModel];
    e.extras = @{ @"list" : list };
    [self addEvent:e];
}

- (void)trackViewGuide {
    TrackingEventModel* e = [TrackingEventModel trackEvent:@"view"
                                              withGuideKey:[FIRTrackProxy guideKey]
                                                   andData:nil];
    [self addEvent:e];
    [FIRAnalytics logEventWithName:@"screen_view"
                           parameters:@{
                                        @"screen_name":@"Collection Screen"
                                        }];
}

- (void)trackNavTap:(NSString *)item {
    NSString* _item = item;
    if (!_item) {
        _item = @"";
    }
    
    [FIRAnalytics logEventWithName:@"nav_click"
                           parameters:@{
                                        @"name":item
                                        }];

}

- (void)trackScanAttempt {
    TrackingEventModel* e = [TrackingEventModel trackEvent:@"scan-attempt"
                                              withGuideKey:[FIRTrackProxy guideKey]
                                                   andData:nil];
    [self addEvent:e];
}

- (void)trackScanError {
    TrackingEventModel* e = [TrackingEventModel trackEvent:@"scan-error"
                                              withGuideKey:[FIRTrackProxy guideKey]
                                                   andData:nil];
    [self addEvent:e];
}

- (void)trackScanSuccess:(CatalogModel *)c withPage:(PageModel *)p {
    self.catalogModel = c;
    self.pageModels = @[p];
    [self trackPageScan];
}

- (void)trackViewCart {
    TrackingEventModel* e = [TrackingEventModel
                             viewCartInCatalog:self.catalogModel];
    [self addEvent:e];
}

- (void)trackViewWishlist {
    TrackingEventModel* e = [TrackingEventModel
                             viewWishlistInCatalog:self.catalogModel];
    [self addEvent:e];
}

- (void)trackViewScanner {
    TrackingEventModel* e = [TrackingEventModel viewScan];
    [self addEvent:e];
}

- (void)trackViewMore {
    TrackingEventModel* e = [TrackingEventModel viewMore];
    [self addEvent:e];
}

- (void)trackAppOpen {
    if (self.catalogModel) {
        TrackingEventModel* event = [TrackingEventModel
                                     viewCatalog:self.catalogModel];
        [self addEvent:event];
    }
}

- (void)trackAppClose {
    if (self.catalogModel) {
        TrackingEventModel* event = [TrackingEventModel
                                     closeCatalog:self.catalogModel];

        [self addEvent:event];
    }
}

- (void)trackViewCatalog {
    [self trackAppOpen];
    
    if (self.catalogModel) {
        
        [FIRAnalytics logEventWithName:@"select_content"
                            parameters:@{
                                @"content_type": @"publication",
                                @"content_id": self.catalogModel.ID,
                                @"name": self.catalogModel.title
                            }];
        
        [FIRAnalytics logEventWithName:@"pub_view"
                            parameters:@{
                                @"path": self.catalogModel.key,
                                @"publication_title": self.catalogModel.title
                            }];
    }
    
}

- (void)trackViewPage {
    if (self.catalogModel && self.pageModels) {
        PageModel* leftPage = [self.pageModels firstObject];
        if (!leftPage) {
            return;
        }
        NSArray* videoModels = leftPage.videoModels;

        [FIRAnalytics logEventWithName:@"page_view"
                            parameters:@{
                                @"page_location": leftPage.pageNumberAsString,
                                @"publication_title": self.catalogModel.title
                            }];
        
        for (VideoModel* v in videoModels) {
            [self trackViewVideo:v];
        }
    }
}

- (void)trackTapElement {
    if (self.elementModel && self.catalogModel && self.pageModels) {
        for (PageModel* page in self.pageModels) {
            if ([page.elementModels containsObject:self.elementModel]) {
                [self addEvent:[TrackingEventModel tapElement:self.elementModel
                                                       onPage:page
                                                    inCatalog:self.catalogModel]];
                break;
            }
        }
    }
}

- (void)trackViewProduct {
    if (self.productModel && self.catalogModel && self.pageModels) {
        for (PageModel* page in self.pageModels) {
            for (ElementModel* element in page.elementModels) {
                if ([element.productID isEqualToString:self.productModel.ID]) {
                    self.elementModel = element;
                    [self addEvent:[TrackingEventModel tapElement:self.elementModel
                                                           onPage:page
                                                        inCatalog:self.catalogModel]];
                    return;
                }
            }
        }
    }
}


- (void)trackSharePage {
    if (self.pageModels && self.catalogModel && self.shareSite) {
        PageModel* page = [self.pageModels firstObject];
        [self addEvent:[TrackingEventModel sharePage:page
                                           inCatalog:self.catalogModel
                                              onSite:self.shareSite]];
    }
}
    
- (void)trackShareSpread {
    if (self.pageModels && self.catalogModel && self.shareSite) {
        PageModel* page = [self.pageModels firstObject];
        [self addEvent:[TrackingEventModel shareSpreadWithLeftPage:page
                                                         inCatalog:self.catalogModel
                                                            onSite:self.shareSite]];
    }
}

- (void)trackShareProduct {
    if (self.productModel && self.elementModel && self.pageModels && self.catalogModel && self.shareSite) {
        for (PageModel* page in self.pageModels) {
            for(ElementModel* elementModel in page.elementModels){
                if([elementModel.productID isEqualToString:self.productModel.ID]){
                    [self addEvent:[TrackingEventModel
                                    shareProduct:self.productModel
                                    ofElement:self.elementModel
                                    onPage:page
                                    inCatalog:self.catalogModel
                                    onSite:self.shareSite]];
                    break;
                }
            }
        }
    }
}

-(void)trackLinkClick:(NSString *)url {
    if (url != nil) {
        [FIRAnalytics logEventWithName:@"link_click"
                            parameters:@{
                                @"url": url
                            }];
    }
}

- (void)trackTapShopNow {
    if (self.productModel && self.catalogModel && self.pageModels) {
        for (PageModel* page in self.pageModels) {
            for (ElementModel* element in page.elementModels) {
                if ([element.productID isEqualToString:self.productModel.ID]) {
                    
                    self.elementModel = element;
                    [FIRAnalytics logEventWithName:@"view_item"
                                        parameters:@{
                                            @"id": self.productModel.ID,
                                            @"price": self.productModel.price,
                                            @"name": self.productModel.name,
                                            @"brand": self.productModel.brand,
                                            @"price": self.productModel.price
                                        }];
                    
                    [FIRAnalytics logEventWithName:@"pdp_link_click"
                                        parameters:@{
                                            @"id": self.productModel.ID,
                                            @"price": self.productModel.price,
                                            @"name": self.productModel.name,
                                            @"brand": self.productModel.brand,
                                            @"price": self.productModel.price
                                        }];
                    return;
                }
            }
        }
    }
}

- (void)trackTOCShow {
    if (self.catalogModel) {
        [self addEvent:[TrackingEventModel showTOCInCatalog:self.catalogModel]];
    }
}

- (void)trackTOCClose {
    if (self.catalogModel) {
        [self addEvent:[TrackingEventModel closeTOCInCatalog:self.catalogModel]];
    }
}

- (void)trackTOCSelection {
    if (self.catalogModel && self.pageModels) {
        PageModel* leftPage = [self.pageModels firstObject];
        [self addEvent:[TrackingEventModel selectPage:leftPage
                                       inTOCOfCatalog:self.catalogModel]];
    }
}

- (void)trackPageZoom {
    if (self.catalogModel && self.pageModels) {
        PageModel* leftPage = [self.pageModels firstObject];
        [self addEvent:[TrackingEventModel zoomPage:leftPage
                                          inCatalog:self.catalogModel]];
    }
}

- (void)trackPageScan {
    if (self.catalogModel && self.pageModels) {
        PageModel* leftPage = [self.pageModels firstObject];
        TrackingEventModel* event = [TrackingEventModel
                                     trackEvent:@"scan"
                                     onPage:leftPage
                                     inCatalog:self.catalogModel
                                     withData:nil];
        [self addEvent:event];
    }
}

- (void)stopTracking {
    if (!self.awaitingInterval) {
        // Tracking is already paused.
        return;
    }

    self.awaitingInterval = NO;
    // Since we can't stop the current interval/sendEvents signal we move
    // the cache and empty it.
    self.pausedCache = [NSArray arrayWithArray:self.cache];
    self.cache = @[];
}

- (void)startTracking {
    if (self.awaitingInterval) {
        // We are already waiting for the next interval to clear.
        return;
    }
    self.awaitingInterval = YES;
    // We restore the cache to what it was previously (before we stoppedTracking).
    self.cache = [NSArray arrayWithArray:self.pausedCache];
    self.pausedCache = @[];

    @weakify(self);
    [[[[RACSignal empty] delay:self.interval] deliverOn:[RACScheduler mainThreadScheduler]] subscribeCompleted:^{
        @strongify(self);
        [self sendEvents];
    }];
}

#pragma mark - Helpers

- (PageModel*)findProductPage:(ProductEntityModel*)product {
    for (PageModel* page in self.pageModels) {
        for (ElementModel* element in page.elementModels) {
            NSLog(@"%@ ? %@", element.productID, product.ID);
            if ([element.productID isEqualToString:product.ID] ||
                [element.productID isEqualToString:product.parent.ID]) {
                return page;
            }
        }
    }
    return nil;
}

- (PageModel*)findProductGroupPage:(ProductGroupModel*)product {
    for (PageModel* page in self.pageModels) {
        for (ElementModel* element in page.elementModels) {
            NSLog(@"%@ ? %@", element.productID, product.ID);
            if ([element.productID isEqualToString:product.ID] ||
                [element.productID isEqualToString:product.ID]) {
                return page;
            }
        }
    }
    return nil;
}


- (PageModel*)findElementPage:(ElementModel*)e {
    for (PageModel* page in self.pageModels) {
        if ([page.elementModels containsObject:e]) {
            return page;
        }
    }
    return nil;
}

- (ElementModel*)findProductElement:(ProductEntityModel*)p {
    for (PageModel* pg in self.pageModels) {
        for (ElementModel* e in pg.elementModels) {
            NSLog(@"%@ ? %@", e.productID, p.ID);
            if ([e.productID isEqualToString:p.ID] ||
                [e.productID isEqualToString:p.parent.ID]) {
                return e;
            }
        }
    }
    return nil;
}

- (ElementModel*)findProductGroupElement:(ProductGroupModel*)p {
    for (PageModel* pg in self.pageModels) {
        for (ElementModel* e in pg.elementModels) {
            NSLog(@"%@ ? %@", e.productID, p.ID);
            if ([e.productID isEqualToString:p.ID] ||
                [e.productID isEqualToString:p.ID]) {
                return e;
            }
        }
    }
    return nil;
}

#pragma mark - Nitty Gritty

static FIRTrackProxy* __defaultFIRTrackProxy = nil;

+ (FIRTrackProxy*)defaultProxy {
    if (!__defaultFIRTrackProxy) {
        __defaultFIRTrackProxy = [[FIRTrackProxy alloc] initWithInterval:INTERVAL];
        __defaultFIRTrackProxy.saveResponses = NO;
        __defaultFIRTrackProxy.conclusions = @[];
    }
    return __defaultFIRTrackProxy;
}

+ (FIRTrackProxy*)sharedProxy {
    return [self defaultProxy];
}

+ (void)setDefaultProxy:(FIRTrackProxy *)proxy {
    __defaultFIRTrackProxy = proxy;
}

- (id)init {
    self = [self initWithInterval:30];
    if (self) {
        self.cache = @[];
        self.pausedCache = nil;
    }
    return self;
}

- (id)initWithInterval:(NSTimeInterval)interval {
    self = [super init];
    if (self) {
        self.cache = @[];
        self.pausedCache = @[];
        self.lastResponse = nil;
        self.interval = interval;
        self.awaitingInterval = NO;
        [self startTracking];
    }
    return self;
}

- (void)sendEvents {
    if ([self.cache count] >= 1) {
        NSArray* precache = [NSArray arrayWithArray:self.cache];
        self.cache = @[];

        // SYN-1816
        //
        // Some events are being doubled and we can't prevent this through the UI.
        // Instead we'll filter the events here.
        NSArray* doubles = @[];
        for (TrackingEventModel* e in precache) {
            for (TrackingEventModel* t in precache) {
                if ([e isEqual:t]) {
                    continue;
                }
                NSTimeInterval dt = fabs(e.timestamp - t.timestamp);
                if (dt <= EVENT_FILTER_INTERVAL && ![doubles containsObject:t] &&
                    [e.event isEqualToString:t.event] &&
                    [e.path isEqualToString:t.path]) {
                    if ((e.data == nil && t.data == nil) || (e.data && t.data && [e.data isEqual:t.data])) {
                        doubles = [doubles arrayByAddingObject:e];
                        break;
                    }
                }
            }
        }

        NSLog(@"%s found %lu double tracking events.",__func__,(unsigned long)[doubles count]);


        NSArray* sentCache = @[];
        for (id item in precache) {
//            if ([doubles containsObject:item]) {
//               // continue;
//                //removes depene
//            }
            
            sentCache = [sentCache arrayByAddingObject:item];
        }
        
        @weakify(self);
        RACSignal* signal = [self sendTrackingBatch:sentCache];
        
        void (^finally)(id) = ^(id response) {
            @strongify(self);
            if (response) {
                self.lastResponse = response;
            }
            self.awaitingInterval = NO;
            [self startTracking];
        };
        
        [signal subscribeNext:^(id response) {
            finally(response);
            if (self.saveResponses) {
                [self reconcileResponse:response withCache:sentCache];
            }
        } error:^(NSError *error) {
            @strongify(self);
            if (self.saveResponses) {
                [self reconcileResponse:nil withCache:sentCache];
            }
            // Add the new events tracked since we sent off the request
            self.cache = [sentCache arrayByAddingObjectsFromArray:self.cache];
            finally(nil);
        }];
    } else {
        self.awaitingInterval = NO;
        [self startTracking];
    }
}

- (void)reconcileResponse:(TrackingResponseModel*)response withCache:(NSArray*)cache {
    NSArray* conclusions = @[];
    for (TrackingEventModel* event in cache) {
        FIRTrackingConclusion* c = [[FIRTrackingConclusion alloc] init];
        c.event = event;
        c.response = response;
        conclusions = [conclusions arrayByAddingObject:c];
    }
    
    self.conclusions = [self.conclusions arrayByAddingObjectsFromArray:conclusions];
}

- (void)addEvent:(TrackingEventModel *)eventModel {
    NSLog(@"%s %@",__func__, eventModel.event);
    self.cache = [self.cache arrayByAddingObject:eventModel];
}

- (RACSignal*)sendTrackingBatch:(NSArray*)cache {

    
    // SYN-1297
    // Search tracking giving an error
    //
    // We don't yet have search-results events on our API, but we need to send
    // them to omniture for MaryKay, which uses AdobeProxy (a subclass of this
    // class) so we just filter them out temporarily.
    NSArray* cache_ = [[cache.rac_sequence filter:^BOOL(TrackingEventModel* t) {
        return ![t.event isEqualToString:@"search-results"];
    }] array];
    
    
    if ([cache_ count] == 0) {
        return [[RACSignal empty] delay:0.001];
    }
    
    return [[FetchProxy fetchTrackingResponseForEvents:cache_] map:^id(id response) {
        return [[TrackingResponseModel alloc] initWithResponseInfo:response];
    }];
}

- (void)collectResponses {
    self.saveResponses = YES;
    self.conclusions = @[];
}

- (void)clearResponses {
    self.saveResponses = NO;
    self.conclusions = @[];
}

- (NSArray*)getResponses {
    return self.conclusions;
}

@end
