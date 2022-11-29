//
//  TrackingEventModel.m
//  SyndecaSDK
//
//  Created by Schell Scivally on 3/25/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "TrackingEventModel.h"
#import "UIDevice+Stats.h"
#import "UIDevice+Resolution.h"
#import "NLS.h"

@implementation TrackingEventModel

- (id)init {
    self = [super init];
    if (self) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
        self.path = @"";
        self.event = @"";
        self.data = @{};
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"TrackingEventModel timestamp:%f\n"
                                      @"                   path:%@\n"
                                      @"                   event:%@\n"
                                      @"                   data:%@",
            self.timestamp,self.path,self.event,self.data];
}

- (id)initWithEvent:(NSString *)event
               path:(NSString *)path
            andData:(NSDictionary *)data {
    self = [self init];
    if (self) {
        self.event = event;
        self.path = path;
        self.data = data;
    }
    return self;
}

- (NSDictionary*)toDictionary {
    return @{ @"ts" : @(self.timestamp),
              @"event" : self.event,
              @"path" : self.path,
              @"data" : self.data ? self.data : @{},
              // SYN-1033 Send device info to tracking
              @"ua" : [TrackingEventModel deviceInfo]
              };
}

+ (NSDictionary*)deviceInfo {
    CGSize size = [[UIDevice currentDevice] screenSize];
    NSString* os = [NSString stringWithFormat:@"%@ %@",
                    [[UIDevice currentDevice] systemName],
                    [[UIDevice currentDevice] systemVersion]];
    NSString* app = [[UIDevice currentDevice] fullAppVersion];
    NSString* locale = [[NLS nls].locale localeIdentifier];
    return @{@"os" : os,
             @"version" : app,
             @"browser" : [[UIDevice currentDevice] browser],
             @"screenResolutionX" : [NSString stringWithFormat:@"%f",size.width],
             @"screenResolutionY" : [NSString stringWithFormat:@"%f",size.height],
             @"locale" : locale
             };
}

+ (TrackingEventModel*)trackEvent:(NSString*)event withGuideKey:(NSString*)key andData:(NSDictionary*)data {
    NSString* path = [NSString stringWithFormat:@"/guide/%@", key];
    TrackingEventModel* e = [[TrackingEventModel alloc] initWithEvent:event path:path andData:data];
    return e;
}

+ (TrackingEventModel*)addToCartElement:(ElementModel*)e onPage:(PageModel *)p inCatalog:(CatalogModel *)c {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@",c.ID,p.ID,e.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:@"cart-add"
                                                                          path:path
                                                                       andData:nil];
    return eventModel;
}

+ (TrackingEventModel*)addToWishlistElement:(ElementModel *)e onPage:(PageModel *)p inCatalog:(CatalogModel *)c {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@",c.ID,p.ID,e.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:@"favorites-add"
                                                                          path:path
                                                                       andData:nil];
    return eventModel;
}

+ (TrackingEventModel*)removeFromWishlistElement:(ElementModel*)e onPage:(PageModel*)p inCatalog:(CatalogModel*)c {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@",c.ID,p.ID,e.ID];
    TrackingEventModel* ev = [[TrackingEventModel alloc] initWithEvent:@"favorites-remove"
                                                                  path:path
                                                               andData:nil];
    return ev;
}

+ (TrackingEventModel*)exportWishlist:(ShoppingCart *)s inCatalog:(CatalogModel *)c {
    TrackingEventModel* eventModel = [[TrackingEventModel alloc]
                                      initWithEvent:@"favorites-email"
                                      path:[NSString stringWithFormat:@"/catalog/%@",c.ID]
                                      andData:nil];

    return eventModel;
}

+ (TrackingEventModel*)exportCart:(ShoppingCart *)s inCatalog:(CatalogModel *)c {
    TrackingEventModel* eventModel = [[TrackingEventModel alloc]
                                      initWithEvent:@"cart-email"
                                      path:[NSString stringWithFormat:@"/catalog/%@",c.ID]
                                      andData:nil];

    return eventModel;
}

+ (TrackingEventModel*)viewCartInCatalog:(CatalogModel *)c {
    return [[TrackingEventModel alloc]
            initWithEvent:@"cart-view"
            path:[NSString stringWithFormat:@"/catalog/%@",c.ID]
            andData:nil];
}

+ (TrackingEventModel*)viewWishlistInCatalog:(CatalogModel *)c {
    return [[TrackingEventModel alloc]
            initWithEvent:@"favorites-view"
            path:[NSString stringWithFormat:@"/catalog/%@",c.ID]
            andData:nil];
}
+ (TrackingEventModel*)viewScan {
    return [[TrackingEventModel alloc] initWithEvent:@"view-scan" path:@"" andData:nil];
}
+ (TrackingEventModel*)viewMore {
    return [[TrackingEventModel alloc] initWithEvent:@"view-more" path:@"" andData:nil];
}

+ (TrackingEventModel*)trackEvent:(NSString*)event
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@",catalogModel.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:event
                                                                          path:path
                                                                       andData:data];
    if(catalogModel){
        eventModel.extras = @{@"catalog" : catalogModel};
    } else {
        eventModel.extras = @{@"catalog" : @"none"};
    }
    
    return eventModel;
}

+ (TrackingEventModel*)closeCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"close" inCatalog:catalogModel withData:nil];
}

+ (TrackingEventModel*)viewCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"view" inCatalog:catalogModel withData:nil];
}

+ (TrackingEventModel*)showTOCInCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"show-toc" inCatalog:catalogModel withData:nil];
}

+ (TrackingEventModel*)closeTOCInCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"hide-toc" inCatalog:catalogModel withData:nil];
}

#pragma mark Page
+ (TrackingEventModel*)trackEvent:(NSString*)event
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@",catalogModel.ID,pageModel.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:event path:path andData:data];
    eventModel.extras = @{ @"catalog" : catalogModel,
                           @"page" : pageModel
                           };
    return eventModel;
}

+ (TrackingEventModel*)viewPage:(PageModel*)pageModel
                      ofCatalog:(CatalogModel*)catalegModel {
    return [self trackEvent:@"page-view" onPage:pageModel inCatalog:catalegModel withData:nil];
}

+ (TrackingEventModel*)viewSpreadWithLeftPage:(PageModel *)leftPage
                                    ofCatalog:(CatalogModel *)catalogModel {
    return [self trackEvent:@"spread-view" onPage:leftPage inCatalog:catalogModel withData:nil];
}

+ (TrackingEventModel*)sharePage:(PageModel *)pageModel
                       inCatalog:(CatalogModel *)catalogModel
                          onSite:(NSString *)siteKey {
    return [self trackEvent:@"page-share" onPage:pageModel inCatalog:catalogModel withData:@{@"site_key":siteKey}];
}

+ (TrackingEventModel*)shareSpreadWithLeftPage:(PageModel *)pageModel
                                     inCatalog:(CatalogModel *)catalogModel
                                        onSite:(NSString *)siteKey {
    return [self trackEvent:@"spread-share" onPage:pageModel inCatalog:catalogModel withData:@{@"site_key":siteKey}];
}

+ (TrackingEventModel*)selectPage:(PageModel*)pageModel
                   inTOCOfCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"select-toc" onPage:pageModel inCatalog:catalogModel withData:nil];
}

+ (TrackingEventModel*)zoomPage:(PageModel*)pageModel
                      inCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"zoom" onPage:pageModel inCatalog:catalogModel withData:nil];
}

#pragma mark Element

+ (TrackingEventModel*)tapMediaOfProduct:(ProductGroupModel*)productModel
                                  onPage:(PageModel*)pageModel
                               inCatalog:(CatalogModel*)catalogModel {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@",catalogModel.ID, pageModel.ID, productModel.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:@"click-media-embed"
                                                                          path:path
                                                                       andData:nil];
    
    eventModel.extras = @{ @"catalog" : catalogModel,
                           @"page" : pageModel,
                           @"product" : productModel
                           };
    return eventModel;
}

+ (TrackingEventModel*)tapElement:(ElementModel*)elementModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@",catalogModel.ID, pageModel.ID, elementModel.ID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:@"click"
                                                                          path:path
                                                                       andData:nil];
    
    eventModel.extras = @{ @"catalog" : catalogModel,
                           @"page" : pageModel,
                           @"element" : elementModel
                           };
    return eventModel;
}

+ (TrackingEventModel*)visitElementLink:(ElementLinkModel*)elementLinkModel
                                 onPage:(PageModel*)pageModel
                              inCatalog:(CatalogModel*)catalogModel {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/link/%@",catalogModel.ID,pageModel.ID,elementLinkModel.linkID];
    TrackingEventModel* eventModel = [[TrackingEventModel alloc] initWithEvent:@"click" path:path andData:nil];
    
    eventModel.extras = @{ @"catalog" : catalogModel,
                           @"page" : pageModel,
                           @"link" : elementLinkModel
                           };
    return eventModel;
}

#pragma mark - Product
+ (TrackingEventModel*)trackEvent:(NSString*)e
                      withElement:(ElementModel*)elementModel
                       andProduct:(ProductGroupModel*)productModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel
                         withData:(NSDictionary*)data {
    NSString* path = [NSString stringWithFormat:@"/catalog/%@/page/%@/product/%@/link/%@",catalogModel.ID, pageModel.ID, elementModel.ID, productModel.url1_link_id];
    TrackingEventModel* event = [[TrackingEventModel alloc] initWithEvent:e path:path andData:data];
    event.extras = @{ @"catalog" : catalogModel,
                      @"page" : pageModel,
                      @"product" : productModel,
                      @"element" : elementModel
                      };
    return event;
}

+ (TrackingEventModel*)tapProduct:(ProductGroupModel*)productModel
                        ofElement:(ElementModel*)elementModel
                           onPage:(PageModel*)pageModel
                        inCatalog:(CatalogModel*)catalogModel {
    return [self trackEvent:@"click"
                withElement:elementModel
                 andProduct:productModel
                     onPage:pageModel
                  inCatalog:catalogModel
                   withData:nil];
}

+ (TrackingEventModel*)shareProduct:(ProductGroupModel*)productModel
                          ofElement:(ElementModel*)elementModel
                             onPage:(PageModel*)pageModel
                          inCatalog:(CatalogModel*)catalogModel
                             onSite:(NSString*)siteKey {
    return [self trackEvent:@"share"
                withElement:elementModel
                 andProduct:productModel
                     onPage:pageModel
                  inCatalog:catalogModel
                   withData:@{@"site_key":siteKey}];
}

@end
