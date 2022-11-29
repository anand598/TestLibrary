//
//  ProductModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/11/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "ProductModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIImageView+Offline.h"
#import "NLS.h"
#import "ExternalLinkParams.h"
#import "ShareItem.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "SwatchModel.h"
#import "SyndecaService.h"


@implementation ProductModel

static BOOL __isScanAndShop = false;
+ (BOOL)isScanAndShop {
    return __isScanAndShop;
}

+ (void)setIsScanAndShop:(BOOL)isScanShop {
    __isScanAndShop = isScanShop;
}

SYNTHESIZE_DI

- (id)initWithInfo:(NSDictionary *)info {
    self = [super initWithInfo:info];
    if (self) {
        self.associatedElements = @[];
    }
    return self;
}

- (NSString*)localizedPriceString {
    NSLocale* locale = [NLS nls].locale;
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = locale;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    CGFloat price = self.priceFloat;
    if (self.priceSaleFloat && self.priceSaleFloat < self.priceFloat) {
        price = self.priceSaleFloat;
    }
    NSNumber* num = [NSNumber numberWithFloat:price];
    return [formatter stringFromNumber:num];
}

- (NSArray*)allImageURLs {
    NSArray* set = [NSArray array];
    if (self.previewURL) {
        set = [set arrayByAddingObject:self.previewURL];
    }
    
    set = [set arrayByAddingObjectsFromArray:self.altImageURLs];
    
    for (ProductModel* e in self.entities) {
        set = [set arrayByAddingObjectsFromArray:e.allImageURLs];
    }
    
    NSArray* list = [[NSSet setWithArray:set] allObjects];
    return list;
}

- (NSURL*)URLForSharing {
    return [[ExternalLinkParams sharedParams] appendParamsToURL:self.url1];
}

- (NSString*)textForSharingForActivity:(NSString*)a {
    NSString* shareTitle = [[NLS nls] stringFor:@"share.socialTitle"
                                        default:@"Share"];
    NSString* productTitle = self.title;
    if ([a isEqualToString:UIActivityTypePostToTwitter]) {
        return productTitle;
    }
    return [NSString stringWithFormat:@"%@\n%@", shareTitle, productTitle];
}

- (RACSignal*)imageForSharing {
    UIImageView* i = [[UIImageView alloc] init];
    return [i loadImageWithURL:self.previewURL];
}

- (NSArray*)activityItems {
    return @[ [[ShareItem alloc] initWithPlaceholderItem:self.title andSignal:[self imageForSharing]],
              [[ShareItem alloc] initWithPlaceholderItem:self.title andBlock:^id(NSString *a) {
                  return [self textForSharingForActivity:a];
              }],
              [[ShareItem alloc] initWithItem:[self URLForSharing]]];
}

- (ShareType)typeForSharing {
    return ShareTypeProduct;
}

- (NSString*)promoMessage {
    NSString* msg = [self.info stringByKey:@"promo_message"];
    return msg;
}

- (NSArray*)entities {
    NSArray* entityInfos = [self.info arrayByKey:@"entities"];
    NSArray* entities = @[];
    for (NSDictionary* entity in [entityInfos objectEnumerator]) {
        ProductModel* model = [[[self class] alloc] initWithInfo:entity];
        model.parent = self;
        model.catalog = self.catalog;
        entities = [entities arrayByAddingObject:model];
    }
    return entities;
}

- (NSString*)cellTitle {
    return [self name];
}

- (NSString*)cellDescription {
    return [self.info stringByKey:@"description"];
}

- (NSString*)name {
    return [self.info stringByKey:@"name"];
}

- (void)setTitle:(NSString *)title {
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:self.info];
    info[@"name"] = title;
    self.info = [NSDictionary dictionaryWithDictionary:info];
}

- (NSString*)productDescription {
    NSString* d = [self.info stringByKey:@"description"];
    return d == nil ? self.firstEntity.productDescription : d;
}

- (NSString*)rawDescription {
    return [self.info stringByKey:@"description"];
}

- (NSURL*)previewURL {
    // Take the first entity's previewURL if this is a product group.
    if (self.firstEntity) {
        return self.firstEntity.previewURL;
    }
    
    NSArray* getters = @[@"image",@"image_large",@"image_link",@"ImagUrl"];
    for (NSString* get in getters) {
        NSString* path = self.info[get];
        if (path && ![path isEqualToString:@"NULL"] && ![path isEqualToString:@"null"]) {
            return [NSURL URLWithString:path];
        }
    }
    
    return nil;
}

- (ProductModel*)firstEntity {
    if (self.entities && [self.entities count]) {
        return self.entities[0];
    }
    return nil;
}

- (NSString*)price {
    if (self.firstEntity) {
        return self.firstEntity.price;
    }
    
    NSString* price = [self.info stringByKey:@"price"];
    if (price && ![price isEqualToString:@""]) {
        // Price could be a number string @"32.87"
        // or it could be some messaging @"See website"
        return price;
    }
    
    if ([self priceIsUnavailable]) {
        // Price is unavailable but NOT a string.
        return @"";
    }
   
    return nil;
}

- (CGFloat)priceFloat {
    if (self.firstEntity) {
        return self.firstEntity.priceFloat;
    }
    
    CGFloat price = [self.info floatByKey:@"price"];
    if (price == CGFLOAT_MAX) {
        price = [self.info floatByKey:@"price_list"];
    }
    
    if (price == CGFLOAT_MAX) {
        NSString* priceString = [self.info stringByKey:@"price"];
        price = [priceString floatValue];;
    }
    
    
    return price == CGFLOAT_MAX ? 0 : price;
}

- (CGFloat)priceSaleFloat {
    if (self.firstEntity) {
        return self.firstEntity.priceSaleFloat;
    }
    
    CGFloat price = [self.info floatByKey:@"price_sale"];
    
    if (price == CGFLOAT_MAX) {
        NSString* priceString = [self.info stringByKey:@"price_sale"];
        price = [priceString floatValue];;
    }
    
    return price == CGFLOAT_MAX ? 0 : price;
}

- (BOOL)priceIsUnavailable {
    if (self.firstEntity) {
        return self.firstEntity.priceIsUnavailable;
    }
    CGFloat price = [self.info floatByKey:@"price"];
    return price == CGFLOAT_MAX || price == 0.0;
}

- (BOOL)hasPriceRange {
    return NO;
}

- (NSArray*)priceRange {
    return nil;
}

- (NSDictionary*)priceView {
    if (self.firstEntity) {
        return self.firstEntity.priceView;
    }
    return [self.info infoByKey:@"PriceView"];
}

- (NSString*)priceTitle {
    if (self.firstEntity) {
        return self.firstEntity.priceTitle;
    }
    NSString* price = [self price];
    
    if (!price) {
        return nil;
    }
    
    NSString* priceSale = [self.info stringByKey:@"price_sale"];
    if (priceSale && ![priceSale isEqualToString:@""] && ![priceSale isEqualToString:price]) {
        return @"Sale:";
    }
    
    return @"Price:";
}

- (NSString*)originalPrice {
    if (self.firstEntity) {
        return self.firstEntity.originalPrice;
    }
    NSString* priceList = [self.info stringByKey:@"price_list"];
    if (priceList && ![priceList isEqualToString:@""]) {
        return priceList;
    }
    
    return nil;
}

- (NSString*)originalPriceTitle {
    if (self.firstEntity) {
        return self.firstEntity.originalPriceTitle;
    }
    NSString* originalPrice = [self originalPrice];
    
    if (originalPrice) {
        return @"After Sale:";
    }
    
    return nil;
}

- (NSArray*)altImageURLs {
    if (self.firstEntity) {
        return self.firstEntity.altImageURLs;
    }
    
    NSArray* getters = @[@"additional_image_link",@"alt_images_large",@"AltImageUrls"];
    for (NSString* get in getters) {
        NSArray* alts = [self.info arrayByKey:get];
        
        if (alts && [alts respondsToSelector:@selector(indexOfObject:)]) {
            NSArray* urls = @[];
            for (NSString* alt in alts) {
                urls = [urls arrayByAddingObject:[NSURL URLWithString:alt]];
            }
            return urls;
        }
    }
    return nil;
}

// returns an array of SwatchModels
- (NSArray*)swatches {
    NSArray* swatches = @[];
    for (ProductModel* entity in self.entities) {
        SwatchModel* swatch = [[SwatchModel alloc] init];
        swatch.name = [entity.info stringByKey:@"color_name"];
        if (!swatch.name) {
            swatch.name = entity.name;
        }
        NSArray* getters = @[@"swatch_image",@"swatch_image_link",@"syndeca_swatch_image_link",@"image_link"];
        NSString* path = nil;
        for (NSString* get in getters) {
            path = [entity.info stringByKey:get];
            if (path) {
                break;
            }
        }
        swatch.imageURL = [NSURL URLWithString:path];
        swatch.zoomURL = entity.previewURL;
        swatches = [swatches arrayByAddingObject:swatch];
    }
    
    return swatches;
}

- (NSString*)title {
    return [self name];
}

- (NSString*)subtitle {
    NSString* subtitle = [self.info stringByKey:@"Brand"];
    
    if (subtitle) {
        return subtitle;
    }
    
    subtitle = [self.info stringByKey:@"sku"];
    
    if (subtitle) {
        return subtitle;
    }
    
    subtitle = [self.info stringByKey:@"key"];
    if (subtitle) {
        return [NSString stringWithFormat:@"Item # %@",subtitle];
    }
    
    return nil;
}

- (NSString*)syndecaCTATitle {
    NSString* d = [self.info stringByKey:@"cta"];
    return d == nil ? self.firstEntity.syndecaCTATitle : d;
}

- (NSArray*)features {
    NSArray* features = [self.info arrayByKey:@"Features"];
    if (features && [features respondsToSelector:@selector(indexOfObject:)]) {
        return features;
    }
    
    NSArray* fs = @[];
    for (NSString* f in [self.info arrayByKey:@"features"]) {
        fs = [fs arrayByAddingObject:f];
    }
    return fs;
}

- (NSURL*)url1 {
    if (self.firstEntity) {
        return self.firstEntity.url1;
    }
    
    NSString* path = [self.info stringByKey:@"url1"];
    // SYN-487 url1 is being passed as a boolean false, which gets turned into
    // "0"
    if ([path isEqualToString:@"0"]) {
        return nil;
    }
    
    // The platform sometimes sends back a url with {{viewer_var}} in it,
    // which means 'replace this with whatever client you are'...
    path = [path stringByReplacingOccurrencesOfString:@"{{viewer_var}}" withString:@"ios"];
    NSURL* url = [NSURL URLWithString:path];
    return [[ExternalLinkParams sharedParams] appendParamsToURL:url];
}

- (NSURL*)url1_tracking{
        if (self.firstEntity) {
                return self.firstEntity.url1_tracking;
            }
    
        NSString* path = [self.info stringByKey:@"url1"];
        // SYN-487 url1 is being passed as a boolean false, which gets turned into
        // "0"
        if ([path isEqualToString:@"0"]) {
                return nil;
            }
    
    
        // The platform sometimes sends back a url with {{viewer_var}} in it,
        // which means 'replace this with whatever client you are'...
        path = [path stringByReplacingOccurrencesOfString:@"{{viewer_var}}" withString:@"ios"];
    
    
    
    //check if there is a hashmarker
        NSString *splitterString = @"#";
        NSRange range = [path rangeOfString:splitterString];
    
        NSString *hashMarkerString = @"";
        if (range.location != NSNotFound) {
            NSArray *tempArray = [path componentsSeparatedByString:splitterString];
            path = tempArray[0];
            hashMarkerString = tempArray[1];
            
            //check if there is some information (catalog id) after the hashmarker.
            
            NSString *nextSplitterString = @"/";
            NSRange nextRange = [hashMarkerString rangeOfString:nextSplitterString];
            
            //we split the string into the hashmarker, and the /catalog-id
            if(range.location != NSNotFound){
                NSArray *nextTempArray = [hashMarkerString componentsSeparatedByString:nextSplitterString];
                path = [path stringByAppendingString:nextSplitterString];
                path = [path stringByAppendingString:nextTempArray[1]];
                
                hashMarkerString = nextTempArray[0];
            }
            
        } else {
            NSLog(@"hashmarker not found");
        }
    
    
    
    //we check if the current url has an initial query parameter
    //this isn't always at the end of the url
    //if this exists, we need to append our tracking information here
    NSString *splitterStringQuery = @"?";
    NSRange rangeQuery = [path rangeOfString:splitterStringQuery];
    
    //this is the current query string, we start with ? because this will be removed anyway
    NSString *queryString = @"?";
    
    //this will hold the parts after the query string, we'll add it back in later.
    NSString *finalUrlValHolder = @"";
    if (range.location != NSNotFound) {
        NSArray *tempArray = [path componentsSeparatedByString:splitterStringQuery];
        path = tempArray[0];
        queryString = @"?";
        queryString = [queryString stringByAppendingString:tempArray[1]];
        
        //check if there is some information (catalog id) after the hashmarker.
        
        NSString *nextSplitterString = @"/";
        NSRange nextRange = [queryString rangeOfString:nextSplitterString];
        
        //we split the string into the hashmarker, and the /catalog-id
        if(range.location != NSNotFound){
            NSArray *nextTempArray = [queryString componentsSeparatedByString:nextSplitterString];
            //path = [path stringByAppendingString:nextSplitterString];
            finalUrlValHolder = nextTempArray[1];
            //path = [path stringByAppendingString:nextTempArray[1]];
            
            queryString = nextTempArray[0];
        }
        
    } else {
        NSLog(@"query string not found");
    }
    
    
    
    
        NSString* userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    
    
        NSString* price = self.price;
        price = [price stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
        if(price == nil){
                price = @"0";
            }
        NSString* quantity = @"1";
        NSString* sku = [self.info stringByKey:@"sku"];
    
    
    
        if(sku == nil){
                sku = @"0";
            }
    
    NSString* catalogID = @"";
    if(self.catalog == nil){
        
    } else {
        catalogID = self.catalog.ID;
    }
    
    
    NSString* guideKey = @"";
    if([SyndecaService sharedService] != nil){
        if([SyndecaService sharedService].config != nil){
            if([SyndecaService sharedService].config.guideKey != nil){
                guideKey = [SyndecaService sharedService].config.guideKey;
            }
        }
    }
    
    //here we add all information to the query string
    
    //if there is no initial parameter, we don't do anything
    if([queryString isEqualToString:@""]){
    }
    else{
        //else, we add an & to the end of the string
        queryString = [queryString stringByAppendingString:@"&"];
    }
    
    queryString = [queryString stringByAppendingString:@"synu="];
    queryString = [queryString stringByAppendingString:userId];
    
    queryString = [queryString stringByAppendingString:@"&syns="];
    queryString = [queryString stringByAppendingString:sku];
    
    queryString = [queryString stringByAppendingString:@"&synp="];
    queryString = [queryString stringByAppendingString:price];
    
    queryString = [queryString stringByAppendingString:@"&synq="];
    queryString = [queryString stringByAppendingString:quantity];
    
    queryString = [queryString stringByAppendingString:@"&sync="];
    queryString = [queryString stringByAppendingString:catalogID];
    
    queryString = [queryString stringByAppendingString:@"&syng="];
    queryString = [queryString stringByAppendingString:guideKey];
    
    //then we add the query string back to the url
    path = [path stringByAppendingString:queryString];
    
    
    
    if(![hashMarkerString isEqualToString:@""]){
        path = [path stringByAppendingString:@"#"];
        path = [path stringByAppendingString:hashMarkerString];
    }
    
    
    //and we add the final url part to the end
    path = [path stringByAppendingString:@"/"];
    path = [path stringByAppendingString:finalUrlValHolder];
    
        NSURL* url = [NSURL URLWithString:path];
        return [[ExternalLinkParams sharedParams] appendParamsToURL:url];
    }


- (NSURL*)url1_shareurl {
    if (self.firstEntity) {
        return self.firstEntity.url1_shareurl;
    }
    return [NSURL URLWithString:[self.info stringByKey:@"url1_shareurl"]];
}

- (NSString*)url1_link_id {
    if (self.firstEntity) {
        return self.firstEntity.url1_link_id;
    }
    NSString* linkID = [self.info stringByKey:@"url1_link_id"];
    if (!linkID) {
        NSNumber* linkNum = [self.info numberByKey:@"url1_link_id"];
        return [linkNum stringValue];
    }
    return linkID;
}

- (NSString*)emailSubject {
    return @"Check out this link!";
}

- (NSString*)brand {
    return [self.info stringByKey:@"Brand"];
}

- (NSString*)styleNum {
    NSUInteger num = [self.info uintByKey:@"StyleNum"];
    if (num == NSUIntegerMax) {
        num = [self.info uintByKey:@"sku"];
    }
    if (num != NSUIntegerMax) {
        return [NSString stringWithFormat:@"Item# %lu",(unsigned long)num];
    }
    return nil;
}

@end
