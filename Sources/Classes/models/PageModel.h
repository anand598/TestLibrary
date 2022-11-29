//
//  PageModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/Shareable.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/ElementModel.h>
#import <SyndecaSDK/VideoModel.h>
#import <SyndecaSDK/DependencyInjection.h>
@class RACSignal;

@interface PageModel : SyndecaModel <DependencyInjection,Shareable>

/** The parent catalog. */
@property (readwrite) CatalogModel* catalog;
/** The index of the page in the catalog.
 
 The pages are zero-indexed, so the first page's index is 0.
 */
@property (readwrite) NSUInteger index;

/** The title of the page. */
-(NSString*)title;
/** The URL of the page's image. */
-(NSURL*)imageURL;
/*&* The URL of the page's thumbnail image. */
-(NSURL*)thumbURL;
/** The width of the page's image. */
-(NSUInteger)width;
/** The height of the page's image. */
-(NSUInteger)height;

/** The page number.
 
 This is provided by the service, and is generally 1 indexed.
 */
-(NSUInteger)number;
/** The page number as a numeric string */
- (NSString*)pageNumberAsString;
/** The element models listed on this page. */
-(NSArray*)elementModels;
/** The element models on this page that are products. */
-(NSArray*)elementModelsThatAreProducts;
/** The element models on this page that are variants, which are part of a product group. */
-(NSArray*)elementModelsThatAreVariants;
/** The element models on this page that are links. 
 
 This will be a list of JSONLinkModels.
 */
-(NSArray*)elementModelsThatAreLinks;
/** The element models on this page that are widgets. */
-(NSArray*)elementModelsThatAreWidgets;
/** The number of products on this page. */
-(NSUInteger)numberOfProducts;
/** The number of links on this page. */
-(NSUInteger)numberOfLinks;
/** The number of widgets on this page. */
-(NSUInteger)numberOfWidgetsOnPage;
/** An array of JSONWidgetModels that are on this page. */
-(NSArray*)widgetModels;
/** The single page sharing key. */
-(NSString*)shareKey;
/** The spread sharing key. */
-(NSString*)spreadShareKey;

#pragma mark - Filtering and Sorting Elements and Products
/** A helper function that filters the given element models by type. */
- (NSArray*)filterElementModelsByType:(ElementModelType)type;
/** A helper that checks whether or not the given element model is stored in the
 given array. */
- (BOOL)isProductElementModel:(ElementModel*)elementModel inArray:(NSArray*)array;
/** Element sort function.
 The sort function to use for ordering product elements. */
- (NSInteger (*)(id,id,void*))productElementSortFunc;
/** The supported element styles. 
 These determine which elements will be considered supported. If the style of
 the element is not listed in this set and the set is non-empty the element
 is considered not-supported. i.e. if the element style is listed in
 this set or this set is empty, it will be considered supported.
 */
- (NSSet*)supportedElementStyles;

#pragma mark - Shareable
/** Returns a signal that will send a UIImage* and then complete. */
- (RACSignal*)imageForSharing;
/** Returns a signal that will send an array of UIActivityItemSources. Preferably three sources to be exact.
 One of an image, one of a string and one of a URL. */
- (RACSignal*)activityItems;
/** The type of thing that is being shared. */ 
- (ShareType)typeForSharing;

#pragma mark - Videos
/** Since videoModels is not a property of the page from the API we have a convenience method that
 searches the parent catalog for widgets matching widget element ids. */
- (NSArray*)videoModels;
/** A convenience method for retrieving a video's associated on-page element using its ID. */
- (ElementModel*)elementWithWidgetID:(NSString*)widgetID;
/** A convenience method for retrieving an on-page element's associated video using its widgetID. */
- (VideoModel*)videoWithWidgetID:(NSString*)widgetID;

@end
