//
//  CatalogModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/AppExtensions.h>
#import <SyndecaSDK/Shareable.h>
#import <SyndecaSDK/GuideModel.h>
#import <SyndecaSDK/DependencyInjection.h>

/** A model that represents a catalog, with pages. */
@interface CatalogModel : SyndecaModel <DependencyInjection,Shareable>
@property (readwrite) GuideModel* guide;

- (AppExtensions*)extensions;
- (NSString*)title;
- (NSString*)buildNum;
- (NSString*)key;
- (BOOL)isVertical;
- (BOOL)isGrid;
- (CGSize)pageSize;
/** The page models in this catalog. 
 An array of PageModels.
 */
- (NSArray*)pageModels;

#pragma mark - Offline Helpers

/** Returns a list of all URLs of page images in this catalog which includes 
 thumbnails and fullsize images.
 */
- (NSArray*)allImageURLs;

@end
