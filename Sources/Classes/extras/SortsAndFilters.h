//
//  SortsAndFilters.h
//  Syndeca iOS SDK
//
//  Created by Schell on 1/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ElementModel.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/PagePanelState.h>

/** A collection of handy sorting and filtering algos. */
@interface SortsAndFilters : NSObject

/** Finds the highest instance of an element that matches a product,
 or nil if none is found. 
 */
+ (ElementModel*)findHighestElementInArray:(NSArray*)elementModels
                                forProduct:(ProductGroupModel*)productModel;
/** Filters duplicate product models. */
+ (NSPredicate*)filterDuplicateProductModels;
/** Sorts an array of products based on element y. */
+ (NSComparator)sortProductsByYAxisUsingElementModels:(NSArray*)elementModels;
/** Sorts and filters products models associated with the given page models using
 the methods above.
 */
+ (NSArray*)sortAndFilterProductModels:(NSArray*)productModels
                        fromPageModels:(NSArray*)pageModels;
/** Sorts and filters pages of products. */
+ (PagePanelState*)generatePagePanelStateFromProducts:(NSArray*)pagesOfProducts
                                                   andPages:(NSArray*)pageModels;
+ (PagePanelState*)generateFilteredPagePanelStateFromProducts:(NSArray *)pagesOfProducts andPages:(NSArray*)pageModels;;
+ (PagePanelState*)generateLinkPanelStateFromPages:(NSArray*)pageModels;
+ (PagePanelState*)generateProductPanelStateFromProducts:(NSArray*)pagesOfProducts
                                                andPages:(NSArray*)pageModels;
+ (PagePanelState*)generatePagePanelStateAsVariantsWithProducts:(NSArray*)pagesOfProducts
                                                       andPages:(NSArray*)pageModels;
+ (PagePanelState*)generateFilteredProductPanelStateWithoutVideosFromProducts:(NSArray*)pagesOfProducts andPages:(NSArray*)pageModels;

@end
