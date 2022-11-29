//
//  PageModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "PageModel.h"
#import "ShareProxy.h"
#import "MasterConfiguration.h"
#import "UIImageView+Offline.h"
#import "ShareItem.h"
#import "VideoModel.h"
#import "NSDictionary+AsObjectOrNil.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PageModel

SYNTHESIZE_DI

/** The title of the page. */
-(NSString*)title {
    return [self.info stringByKey:@"title"];
}

/** The URL of the page's image. */
-(NSURL*)imageURL {
    return [NSURL URLWithString:[self.info stringByKey:@"image_url"]];
}

/*&* The URL of the page's thumbnail image. */
-(NSURL*)thumbURL {
//    return [NSURL URLWithString:[self.info stringByKey:@"image_url"]];
    return [NSURL URLWithString:[self.info stringByKey:@"thumb_url"]];
}

/** The width of the page's image. */
-(NSUInteger)width {
    return [self.info uintByKey:@"width"];
}

/** The height of the page's image. */
-(NSUInteger)height {
    return [self.info uintByKey:@"height"];
}

/** The number of the page in the catalog.
 
 This is provided by the service, and is generally 1 indexed.
 */
-(NSUInteger)number {
    return [self.info uintByKey:@"num"];
}

- (NSString*)pageNumberAsString {
    return [self.info stringByKey:@"num"];
}

/** The element models listed on this page. */
-(NSArray*)elementModels {
    NSMutableArray* elementModels = [NSMutableArray array];
    NSArray* elementJSONArray = [self.info arrayByKey:@"elements"];
    if (elementJSONArray) {
        for (int i = 0; i < [elementJSONArray count];  i++) {
            NSDictionary* elementInfo = (NSDictionary*)[elementJSONArray objectAtIndex:i];
            if (elementInfo) {
                ElementModel* elementModel = [[[ElementModel DIClass] alloc] initWithInfo:elementInfo];
                
                if ([elementModel type] == ElementModelType_Link) {
                    // Remap this as a link element model...
                    ElementLinkModel* linkModel = [[[ElementLinkModel DIClass] alloc] initWithInfo:elementInfo];
                    elementModel = linkModel;
                }
                
                // Skip any elements that are not supported or are disabled...
                if ([elementModel isDisabled] || ![elementModel isSupported]) {
                    continue;
                }
                [elementModels addObject:elementModel];
            }
        }
    }
    return elementModels;
}

/** The element models on this page that are products. */
-(NSArray*)elementModelsThatAreProducts {
    // A subset of the elements that are products, deduped and
    // ordered by hit area y...
    NSArray* productsWithDupes = [self filterElementModelsByType:ElementModelType_Product];
    // Filter out the dupes...
    NSMutableArray* uniqueProducts = [NSMutableArray array];
    for (ElementModel* elementModel in productsWithDupes) {
        if (![self isProductElementModel:elementModel inArray:uniqueProducts]) {
            [uniqueProducts addObject:elementModel];
        }
    }
    return [uniqueProducts sortedArrayUsingFunction:[self productElementSortFunc] context:NULL];
}
/** The element models on this page that are variants, which are part of a product group. */
-(NSArray*)elementModelsThatAreVariants{
    return [self filterElementModelsByType:ElementModelType_Variant];
}
/** The element models on this page that are links.
 
 This will be a list of JSONLinkModels.
 */
-(NSArray*)elementModelsThatAreLinks {
    return [self filterElementModelsByType:ElementModelType_Link];
}

/** The element models on this page that are widgets. */
-(NSArray*)elementModelsThatAreWidgets {
    return [self filterElementModelsByType:ElementModelType_Widget];
}

/** The number of products on this page. */
-(NSUInteger)numberOfProducts {
    return [[self elementModelsThatAreProducts] count];
}

/** The number of links on this page. */
-(NSUInteger)numberOfLinks {
    return [[self elementModelsThatAreLinks] count];
}

/** The number of widgets on this page. */
-(NSUInteger)numberOfWidgetsOnPage {
    return 0;
}

/** An array of JSONWidgetModels that are on this page. */
-(NSArray*)widgetModels {
    return nil;
}

/** The single page sharing key. */
-(NSString*)shareKey {
    return [self.info stringByKey:@"shareKey"];
}
/** The spread sharing key. */
-(NSString*)spreadShareKey {
    return [self.info stringByKey:@"spreadShareKey"];
};

/** A helper function that filters the given element models by type. */
- (NSArray*)filterElementModelsByType:(ElementModelType)type{
    NSMutableArray* models = [NSMutableArray array];
    for (ElementModel* elementModel in [self elementModels]) {
        if ([elementModel type] == type) {
            [models addObject:elementModel];
        }
    }
    return [NSArray arrayWithArray:models];
}
/** A helper that checks whether or not the given element model is stored in the
 given array. */
- (BOOL)isProductElementModel:(ElementModel*)elementModel inArray:(NSArray*)array {
    NSString* searchID = [elementModel productID];
    for (ElementModel* otherElementModel in array) {
        NSString* productID = [otherElementModel productID];
        if ([productID isEqualToString:searchID]) {
            return YES;
        }
    }
    return NO;
}
/** Element sort function.
 The sort function to use for ordering product elements. */
NSInteger sortByHighPoint(id item1, id item2, void* ctx) {
    CGPoint p1 = [[(ElementModel*)item1 hitAreaPolygon] highestPoint];
    CGPoint p2 = [[(ElementModel*)item2 hitAreaPolygon] highestPoint];
    if (p1.y < p2.y) {
        return NSOrderedAscending;
    } else if (p1.y > p2.y) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSInteger (*)(id,id,void*))productElementSortFunc {
    return sortByHighPoint;
}
/** The supported element styles. 
 These determine which elements will be considered supported. If the style of
 the element is not listed in this set and the set is non-empty the element
 is considered not-supported. i.e. if the element style is listed in
 this set or this set is empty, it will be considered supported.
 */
- (NSSet*)supportedElementStyles {
    return [NSSet set];
}

- (RACSignal*)imageForSharing {
    UIImageView* i = [[UIImageView alloc] init];
    return [i loadImageWithURL:self.imageURL];
}

- (NSURL*)URLForSharing {
    NSString* num = [self pageNumberAsString];
    NSString* url = [[self.info stringByKey:@"shareUrl"] stringByReplacingOccurrencesOfString:@"{{page_var}}" withString:num];
    return [NSURL URLWithString:url]; 
}

- (NSString*)textForSharingForActivity:(NSString *)a {
    NSString* client = [MasterConfiguration sharedConfiguration].clientName;
    return [NSString stringWithFormat:@"%@ - %@",client,self.catalog.title];
}

- (NSArray*)activityItems {
    return @[[[ShareItem alloc] initWithPlaceholderItem:@"image" andSignal:[self imageForSharing]],
             [[ShareItem alloc] initWithPlaceholderItem:@"text" andBlock:^id(NSString *a) {
                 return [self textForSharingForActivity:a];
             }],
             [[ShareItem alloc] initWithItem:[self URLForSharing]]];
}

- (ShareType)typeForSharing {
    return ShareTypePage;
}

#pragma mark - Video stuff
- (NSArray*)videoModels {
    NSArray* vs = @[];
    for (ElementModel* el in self.elementModelsThatAreWidgets) {
        VideoModel* video = [self videoModelWithElement:el];
        vs = [vs arrayByAddingObject:video];
    }
    return vs;
}

- (ElementModel*)elementWithWidgetID:(NSString*)widgetID {
    for (ElementModel* el in self.elementModelsThatAreWidgets) {
        NSString* ID = [[el.info infoByKey:@"data"] stringByKey:@"widgetID"];
        if ([ID isEqualToString:widgetID]) {
            return el;
        }
    }
    return nil;
}

- (VideoModel*)videoWithWidgetID:(NSString*)widgetID {
    return [self videoModelWithElement:[self elementWithWidgetID:widgetID]];
}

- (VideoModel*)videoModelWithElement:(ElementModel*)el {
    NSUInteger ID = [[el.info infoByKey:@"data"] uintByKey:@"widgetID"];
    for (NSDictionary* w in self.catalog.info[@"widgets"]) {
        NSUInteger vID = [w uintByKey:@"id"];
        if (vID == ID) {
            VideoModel* v = [[VideoModel alloc] init];
            v.element = el;
            v.info = w;
            v.page = self;
            return v;
        }
    }
    
    return nil;
}

@end
