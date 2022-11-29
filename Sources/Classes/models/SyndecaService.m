//
//  SyndecaService.m
//  CocoaViewer
//
//  Created by Schell Scivally on 11/15/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "SyndecaService.h"
#import "SyndecaRequest.h"
#import "SyndecaConfig.h"
#import "NSString+Helpers.h"
#import "ExternalLinkParams.h"
#import "UIDevice+Resolution.h"
#import "MasterConfiguration.h"

@implementation SyndecaService

#pragma mark - Default Instance

static SyndecaService* __defaultSyndecaService = nil;
+ (SyndecaService*)sharedService {
    if (!__defaultSyndecaService) {
        __defaultSyndecaService = [[SyndecaService alloc] init];
    }
    return __defaultSyndecaService;
}

+ (void)setSharedService:(SyndecaService *)facade {
    __defaultSyndecaService = facade;
}

#pragma mark - Request Methods

- (SyndecaRequest*)getRequestWithResourceString:(NSString *)resourceString forDelegate:(id<SyndecaRequestDelegate>)delegate {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (self.config.isDebug) {
        [params setObject:@(1) forKey:@"debug"];
    }
    if (self.config.isArchive) {
        [params setObject:@(1) forKey:@"archive"];
    }
    
    NSURL* URL = [NSURL URLWithString:resourceString];
    URL = [ExternalLinkParams appendParams:params toURL:URL];
    SyndecaRequest* request = [[SyndecaRequest alloc] init];
    [request setResource:[URL absoluteString]];
    [request setDelegate:delegate];
    return request;
}

- (NSMutableURLRequest*)guideHeadRequestForDelegate:(id<SyndecaRequestDelegate>)delegate {
    NSString* resource = [[self.config syndecaAPI] stringByAppendingFormat:@"guide/%@", self.config.guideKey];
    
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        resource = [[self.config syndecaAPI] stringByAppendingFormat:@"shop-catalogs/%@", self.config.guideKey];
    }
    
    SyndecaRequest* request =  [self getRequestWithResourceString:resource forDelegate:delegate];
    NSString *urlString = request.resource;
    NSURL *requestedURL = [NSURL URLWithString:urlString];
    //    NSMutableURLRequest *headerRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
    //                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
    
    NSMutableURLRequest *headerRequest = [NSMutableURLRequest requestWithURL:requestedURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
    [headerRequest setHTTPMethod:@"HEAD"];
    
    
    return headerRequest;
}

- (SyndecaRequest*)guideRequestForDelegate:(id<SyndecaRequestDelegate>)delegate {
    NSString* resource = [[self.config syndecaAPI] stringByAppendingFormat:@"guide/%@", self.config.guideKey];
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        resource = [[self.config syndecaAPI] stringByAppendingFormat:@"shop-catalogs/%@", self.config.guideKey];
    }
    
    SyndecaRequest* request =  [self getRequestWithResourceString:resource forDelegate:delegate];
    [request setType:SyndecaRequestType_Guide];
    return request;
}

- (SyndecaRequest*)catalogRequestWithId:(NSString *)ID andBuildNum:(NSString *)buildNum forDelegate:(id<SyndecaRequestDelegate>)delegate {
    NSString* resource = [self.config syndecaAPI];
    resource = [resource stringByAppendingFormat:@"guide/%@/catalog/%@/build/%@",self.config.guideKey,ID,buildNum];
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        resource = [self.config syndecaAPI];
//        resource = [resource stringByAppendingFormat:@"shop-catalogs/@/catalog/%@/build/%@",self.config.guideKey,ID,buildNum];
        resource = [resource stringByAppendingFormat:@"shop-catalogs/%@/catalog/%@/build/%@",self.config.guideKey,ID,buildNum];
    }

    
    resource = [resource stringByAppendingFormat:@"?coord_units=percent&precision=10&display=%@",[[UIDevice currentDevice] resolution]];
    
    SyndecaRequest* request = [self getRequestWithResourceString:resource forDelegate:delegate];
    [request setType:SyndecaRequestType_Catalog];
    return request;
}

- (SyndecaRequest*)productRequestForPageWithNumber:(NSUInteger)from
                                     toPageWithNumber:(NSUInteger)to
                                        withCatalogId:(NSString *)catalogId
                                          andBuildNum:(NSString *)buildNum
                                          forDelegate:(id<SyndecaRequestDelegate>)delegate {
    
    
    NSString* suffix = @"guide/%@/catalog/%@/build/%@/product/query?page_num=%i";
    
    
    NSString* resource = [[self.config syndecaAPI] stringByAppendingFormat:suffix,self.config.guideKey,catalogId,buildNum,from];
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        suffix = @"catalog/%@/build/%@/product/query?page_num=%i";
        resource = [[self.config syndecaAPI] stringByAppendingFormat:suffix,catalogId,buildNum,from];
    }

    
    if (to != from) {
        resource = [resource stringByAppendingFormat:@"-%lu",(unsigned long)to];
    }
    
    SyndecaRequest* request = [self getRequestWithResourceString:resource forDelegate:delegate];
    [request setType:SyndecaRequestType_ProductMany];
    return request;
}

- (NSString*)uniqueSessionString {
	char codes[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	time_t t;
	time(&t);
	struct tm* gm;
	gm = gmtime(&t);
	srand((uint)t);
	char uid[37];
	int ndx = 0;
	for (int i = 0; i < 8; i++) {
		uid[ndx++] = codes[rand()%16];
	}
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 4; j++) {
			uid[ndx++] = codes[rand()%16];
		}
	}
	char ct[15];
	strftime(ct, 15, "%Y%m%d%H%M%S", gm);
	uid[ndx++] = '\0';
	char * s = NULL;
	asprintf(&s, "%s-%s", uid, ct);
	NSString* token = [NSString stringWithFormat:@"%s",s];
	return token;
}

- (NSString*)sessionString {
    static NSString* __session = nil;
    if (!__session) {
        __session = [self uniqueSessionString];
    }
    return __session;
}

- (SyndecaRequest*)trackingRequestWithEvents:(NSArray*)events {
    // Convert the event models to dictionaries.
    NSArray* data = @[];
    for (TrackingEventModel* eventModel in events) {
        data = [data arrayByAddingObject:[eventModel toDictionary]];
    }
    // Put that data into another dictionary.
    NSDictionary* payload = @{ @"session_key" : [self sessionString],
                               @"ts" : @([[NSDate date] timeIntervalSince1970]),
                               @"events" : data };
    NSError* error = nil;
    NSData* JSONPayload = [NSJSONSerialization dataWithJSONObject:payload
                                                          options:0
                                                            error:&error];
    
    SyndecaRequest* request = [self getRequestWithResourceString:self.config.trackAPI
                                                     forDelegate:nil];
    NSString* resource = request.resource;
    if ([self.config isDebug]) {
        resource = [resource stringByAppendingString:@"&validate=1"];
    }
    request.resource = resource;
    request.postData = JSONPayload;
    request.type = SyndecaRequestType_Tracking;
    return request;
}

//- (SyndecaRequest*)sharalitySiteListRequest {
//    RequestBuilder* builder = [self newRequestBuilder];
////    [self setDefaultsOnService:builder];
//    NSString* path = [builder.config.shareAPI stringByAppendingString:@"-sites"];
//    SyndecaRequest* request = [builder getRequestWithResourceString:path forDelegate:nil];
//    request.type = SyndecaRequestType_SharalityList;
//    return request;
//}

- (SyndecaRequest*)sharalityEmailURLRequestForShareKey:(NSString*)shareKey {
    NSString* path = self.config.shareAPI;
    path = [path stringByAppendingFormat:@"/%@",shareKey];
    SyndecaRequest* request = [self getRequestWithResourceString:path forDelegate:nil];
    request.type = SyndecaRequestType_SharalityURL;
    return request;
}

- (NSURL*)sharalityURLForSite:(NSString *)siteKey andShare:(NSString *)shareKey {
    NSString* path = self.config.shareAPI;
    path = [path stringByAppendingFormat:@"/%@/302/%@",shareKey,siteKey];
    return [NSURL URLWithString:path];
}

//- (SyndecaRequest*)searchRequestWithText:(NSString*)text andCatalogId:(NSString*)ID {
//    NSString* path = [self.config syndecaAPI];
//    NSString* guide = self.config.guideKey;
//    // MKYQA-184 Search returns no results if leading or trailing spaces are
//    // present
//    path = [path stringByAppendingFormat:@"guide/%@/catalog/%@?q=%@",guide,ID,[text urlEncodedString]];
//    
//    SyndecaRequest* request = [self getRequestWithResourceString:path forDelegate:nil];
//    request.type = SyndecaRequestType_Unknown;
//    return request;
//}

- (SyndecaRequest*)crossCatalogSearchRequestWithText:(NSString*)text {
    NSString* path = [self.config syndecaAPI];
    NSString* guide = self.config.guideKey;
    // MKYQA-184 Search returns no results if leading or trailing spaces are
    // present
    
    path = [path stringByAppendingFormat:@"guide2/%@?q=%@&size=10000",guide,[text urlEncodedString]];
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs){
        path = [self.config syndecaAPI];
        path = [path stringByAppendingFormat:@"shop-catalogs/%@?q=%@&size=10000",guide,[text urlEncodedString]];
    }
    
    SyndecaRequest* request = [self getRequestWithResourceString:path forDelegate:nil];
    request.type = SyndecaRequestType_Unknown;
    return request;
}

- (SyndecaRequest*)searchRequestWithText:(NSString*)text andCatalogId:(NSString*)ID andBuildNum:(NSString*)buildNum {
    NSString* path = [self.config syndecaAPI];
    NSString* guide = self.config.guideKey;
    // MKYQA-184 Search returns no results if leading or trailing spaces are
    // present
    path = [path stringByAppendingFormat:@"guide/%@/catalog/%@/build/%@?q=%@",guide,ID,buildNum,[text urlEncodedString]];
    
    
    //shop catalogs
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        path = [self.config syndecaAPI];
        path = [path stringByAppendingFormat:@"shop-catalogs/%@?q=%@&size=10000",guide,[text urlEncodedString]];
    }
    
    SyndecaRequest* request = [self getRequestWithResourceString:path forDelegate:nil];
    request.type = SyndecaRequestType_Unknown;
    return request;
}

- (SyndecaRequest*)productRequestWithBarcode:(NSString*)code {
    NSString* path = [self.config syndecaAPI];
    NSString* guide = self.config.guideKey;
    path = [path stringByAppendingFormat:@"guide/%@/barcode/%@",guide,code];
    
    SyndecaRequest* request = [self getRequestWithResourceString:path forDelegate:nil];
    request.type = SyndecaRequestType_Unknown;
    return request;
}

@end
