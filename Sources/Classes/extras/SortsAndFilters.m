//
//  SortsAndFilters.m
//  Syndeca iOS SDK
//
//  Created by Schell on 1/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ElementLinkModel.h"
#import "SortsAndFilters.h"
#import "PagePanelItem.h"
#import "VariantModel.h"
#import "VideoModel.h"
#import "MasterConfiguration.h"
#import "UrlModel.h"

@implementation SortsAndFilters

+ (ElementModel*)findHighestElementInArray:(NSArray*)elementModels forProduct:(ProductGroupModel*)productModel {
    ElementModel* highestElement = nil;

    for (ElementModel* elementModel in elementModels) {
        if (![elementModel.productID isEqualToString:productModel.ID]) {
            continue;
        }
        // The element matches, but is it the highest?
        if (!highestElement ||
            [highestElement.hitAreaPolygon highestPoint].y < [elementModel.hitAreaPolygon highestPoint].y) {
                highestElement = elementModel;
        }
    }
    return highestElement;
};

+ (NSComparator)sortProductsByYAxisUsingElementModels:(NSArray*)elementModels {
    return ^NSComparisonResult(id obj1, id obj2) {
        ProductGroupModel* leftProductModel = (ProductGroupModel*)obj1;
        ElementModel* leftElementModel = [SortsAndFilters findHighestElementInArray:elementModels
                                                                         forProduct:leftProductModel];
        ProductGroupModel* rightProductModel = (ProductGroupModel*)obj2;
        ElementModel* rightElementModel = [SortsAndFilters findHighestElementInArray:elementModels
                                                                          forProduct:rightProductModel];
        
        CGFloat diff = [leftElementModel.hitAreaPolygon highestPoint].y - [rightElementModel.hitAreaPolygon highestPoint].y;
        if (diff == 0) {
            return NSOrderedSame;
        }
        if (diff > 0) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    };
}

+ (ProductGroupModel*)productModelFromPagePanelItem:(PagePanelItem*)item {
    switch (item.itemType) {
        case PagePanelItemType_Variant:
            return ((VariantModel*)item.item).productGroup;
        case PagePanelItemType_Product:
            return (ProductGroupModel*)item.item;
        default:
            return nil;
    }
    return nil;
}

+ (NSComparator)sortPagePanelItemsByYAxisUsingElementModels:(NSArray*)els {
    NSComparator sortProducts = [SortsAndFilters
                                 sortProductsByYAxisUsingElementModels:els];
    return ^NSComparisonResult(PagePanelItem* a, PagePanelItem* b) {
        ProductGroupModel* pa = [SortsAndFilters productModelFromPagePanelItem:a];
        ProductGroupModel* pb = [SortsAndFilters productModelFromPagePanelItem:b];
        return sortProducts(pa, pb);
    };
}

+ (NSPredicate*)filterDuplicateProductModels {
    // De-dupe the product models using this list of IDs.
    __block NSArray* productIDs = @[];
    return [NSPredicate predicateWithBlock:^BOOL(ProductGroupModel* productModel, NSDictionary *bindings) {
        if ([productIDs containsObject:productModel.ID]) {
            return NO;
        }
        productIDs = [productIDs arrayByAddingObject:productModel.ID];
        return YES;
    }];
    
}

+ (NSPredicate*)filterDuplicatePagePanelItems {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    
    __block NSPredicate* dedupe = [SortsAndFilters filterDuplicateProductModels];
    return [NSPredicate predicateWithBlock:^BOOL(PagePanelItem* item, NSDictionary *bindings) {
        
//        Here we make sure to deliver every variant tagged on a page. This logic breaks ShopCatalogs - so we run a quick check right here.
//        if(config.isShopCatalogs == false){
//            
//        }
        
//        de-dup
//        if (item.itemType == PagePanelItemType_Variant) {
//            return YES;
//        }
        
        ProductGroupModel* pm = [SortsAndFilters productModelFromPagePanelItem:item];
        return [dedupe evaluateWithObject:pm];
    }];
}

+ (NSArray*)sortAndFilterProductModels:(NSArray*)productModels fromPageModels:(NSArray*)pageModels {
    // Order the products by their page element's y-coord.
    NSArray* elementModels = @[];
    for (PageModel* pageModel in pageModels) {
        elementModels = [elementModels arrayByAddingObjectsFromArray:pageModel.elementModels];
    }
    
    NSComparator yComparitor = [SortsAndFilters sortProductsByYAxisUsingElementModels:elementModels];
    NSArray* orderedItems = [productModels sortedArrayUsingComparator:yComparitor];
    
    // De-dupe the product models using this list of IDs.
    NSPredicate* dedupePredicate = [SortsAndFilters filterDuplicateProductModels];
    NSArray* filteredItems = [orderedItems filteredArrayUsingPredicate:dedupePredicate];
    return filteredItems;
}

+ (PagePanelState*)generateProductPanelStateFromProducts:(NSArray*)pagesOfProducts
                                                andPages:(NSArray*)pageModels {
    NSArray* productHeaders = [[pageModels.rac_sequence map:^NSString*(PageModel* page) {
        return page.title;
    }] array];
    
    // And gather the products by section
    //This does not filter products on multiple pages
    NSArray* productSections = @[];
    for (NSArray* productModels in [pagesOfProducts objectEnumerator]) {
        NSArray* sortedFilteredProductModels = [SortsAndFilters
                                                sortAndFilterProductModels:productModels
                                                fromPageModels:pageModels];
        NSArray* panelItems = @[];
        for (ProductGroupModel* product in sortedFilteredProductModels) {
            PagePanelItem* item = [[PagePanelItem alloc] init];
            item.item = product;
            item.itemType = PagePanelItemType_Product;
            panelItems = [panelItems arrayByAddingObject:item];
        }
        productSections = [productSections arrayByAddingObject:panelItems];
    }
    
    PagePanelState* productsPanel = [[PagePanelState alloc] init];
    productsPanel.sectionHeaderModels = productHeaders;
    productsPanel.itemsBySection = productSections;
    
    return productsPanel;
}

+ (PagePanelState*)generateLinkPanelStateFromPages:(NSArray*)pageModels {
    // Gather links by section
    NSArray* linkHeaders = @[];
    NSArray* linkSections = @[];
    for (PageModel* page in pageModels) {
        if ([page.elementModelsThatAreLinks count] > 0) {
            NSString* linkSection = [page.title stringByAppendingString:@" - Links"];
            linkHeaders = [linkHeaders arrayByAddingObject:linkSection];
            // Map the links in panel items.
            NSArray* items = @[];
            for (ElementModel* element in page.elementModelsThatAreLinks) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = element;
                
                switch (element.type) {
                    case ElementModelType_Link: {
                        ElementLinkModel* link = (ElementLinkModel*)element;
                        if (link.linkType == LinkTypeExternal) {
                            item.itemType = PagePanelItemType_LinkExternal;
                        } else {
                            item.itemType = PagePanelItemType_LinkInternal;
                        }
                        break;
                    }
                        
                    default: {
                        item.itemType = PagePanelItemType_Any;
                        NSLog(@"unhandled element panel type!");
                        break;
                    }
                }
                // SYN-1085
                // De-dupe non-product links
                BOOL isDupe = NO;
                ElementLinkModel* a = (ElementLinkModel*)element;
                for (PagePanelItem* bitem in items) {
                    ElementLinkModel* b = (ElementLinkModel*)bitem.item;
                    BOOL equalIDs = [a.ID isEqualToString:b.ID];
                    BOOL equalTitles = [a.linkTitle isEqualToString:b.linkTitle];
                    BOOL equalURLs = [a.URL isEqualTo:b.URL];
                    if (equalIDs || (equalTitles && equalURLs)) {
                        isDupe = YES;
                        break;
                    }
                }
                
                if (isDupe) {
                    NSLog(@"Caught a dupe link: %@ %@ %@",a.linkID,a.linkTitle,[a.URL asString]);
                } else {
                    items = [items arrayByAddingObject:item];
                }
            }
            linkSections = [linkSections arrayByAddingObject:items];
        }
    }
    PagePanelState* panelState = [[PagePanelState alloc] init];
    panelState.sectionHeaderModels = linkHeaders;
    panelState.itemsBySection = linkSections;
    return panelState;
}

+ (PagePanelState*)generateVideoPanelStateFromPages:(NSArray*)pageModels {
    // Gather videos by section
    NSArray* videoHeaders = @[];
    NSArray* videoSections = @[];
    for (PageModel* page in pageModels) {
        if ([[page videoModels] count] > 0) {
            NSString* videoSection = [page.title stringByAppendingString:@" - Videos"];
            videoHeaders = [videoHeaders arrayByAddingObject:videoSection];
            // Map the videos in panel items.
            NSArray* items = @[];
            for (VideoModel* video in [page videoModels]) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = video;
                item.itemType = PagePanelItemType_Video;
                items = [items arrayByAddingObject:item];
            }
            videoSections = [videoSections arrayByAddingObject:items];
        }
    }
    PagePanelState* panelState = [[PagePanelState alloc] init];
    panelState.sectionHeaderModels = videoHeaders;
    panelState.itemsBySection = videoSections;
    return panelState;
}

+ (PagePanelState*)generateFilteredProductPanelStateFromProducts:(NSArray*)pagesOfProducts
                                                andPages:(NSArray*)pageModels {
    NSArray* productHeaders = [[pageModels.rac_sequence map:^NSString*(PageModel* page) {
        return page.title;
    }] array];
    
    // And gather the products by section
    //This does not filter products on multiple pages
    NSArray* productSections = @[];
    NSArray* panelItems = @[];
    NSArray* allItems = @[];
    for (NSArray* productModels in [pagesOfProducts objectEnumerator]) {
        NSArray* sortedFilteredProductModels = [SortsAndFilters
                                                sortAndFilterProductModels:productModels
                                                fromPageModels:pageModels];
        allItems = [allItems arrayByAddingObjectsFromArray:sortedFilteredProductModels];
    }
    
    NSPredicate* dedupePredicate = [SortsAndFilters filterDuplicateProductModels];
    NSArray* filteredItems = [allItems filteredArrayUsingPredicate:dedupePredicate];
    
    for (ProductGroupModel* product in filteredItems) {
        PagePanelItem* item = [[PagePanelItem alloc] init];
        item.item = product;
        item.itemType = PagePanelItemType_Product;
        panelItems = [panelItems arrayByAddingObject:item];
    }

    // Gather links by section
    NSArray* linkHeaders = @[];
    NSArray* linkSections = @[];
    for (PageModel* page in pageModels) {
        if ([page.elementModelsThatAreLinks count] > 0) {
            NSString* linkSection = [page.title stringByAppendingString:@" - Links"];
            linkHeaders = [linkHeaders arrayByAddingObject:linkSection];
            // Map the links in panel items.
            NSArray* items = @[];
            for (ElementModel* element in page.elementModelsThatAreLinks) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = element;
                
                switch (element.type) {
                    case ElementModelType_Link: {
                        ElementLinkModel* link = (ElementLinkModel*)element;
                        if (link.linkType == LinkTypeExternal) {
                            item.itemType = PagePanelItemType_LinkExternal;
                        } else {
                            item.itemType = PagePanelItemType_LinkInternal;
                        }
                        break;
                    }
                        
                    default: {
                        item.itemType = PagePanelItemType_Any;
                        NSLog(@"unhandled element panel type!");
                        break;
                    }
                }
                // SYN-1085
                // De-dupe non-product links
                BOOL isDupe = NO;
                ElementLinkModel* a = (ElementLinkModel*)element;
                for (PagePanelItem* bitem in items) {
                    ElementLinkModel* b = (ElementLinkModel*)bitem.item;
                    BOOL equalIDs = [a.ID isEqualToString:b.ID];
                    BOOL equalTitles = [a.linkTitle isEqualToString:b.linkTitle];
                    BOOL equalURLs = [a.URL isEqualTo:b.URL];
                    if (equalIDs || (equalTitles && equalURLs)) {
                        isDupe = YES;
                        break;
                    }
                }
                
                if (isDupe) {
                    NSLog(@"Caught a dupe link: %@ %@ %@", a.linkID, a.linkTitle, [a.URL asString]);
                } else {
                   // items = [items arrayByAddingObject:item];
                    panelItems = [panelItems arrayByAddingObject:item];
                }
            }
        }
    }
    
    
    //Gather videos by section
    NSArray* videoHeaders = @[];
    NSArray* videoSections = @[];
    for (PageModel* page in pageModels) {
        if ([[page videoModels] count] > 0) {
            NSString* videoSection = [page.title stringByAppendingString:@" - Videos"];
            videoHeaders = [videoHeaders arrayByAddingObject:videoSection];
            // Map the videos in panel items.
            NSArray* items = @[];
            for (VideoModel* video in [page videoModels]) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = video;
                item.itemType = PagePanelItemType_Video;
                panelItems = [panelItems arrayByAddingObject:item];
            }
        }
    }

    
   
    productSections = [productSections arrayByAddingObject:panelItems];
    
    
    PagePanelState* productsPanel = [[PagePanelState alloc] init];
    productsPanel.sectionHeaderModels = productHeaders;
    productsPanel.itemsBySection = productSections;
    
    return productsPanel;
}

+ (PagePanelState*)generateFilteredProductPanelStateWithoutVideosFromProducts:(NSArray*)pagesOfProducts andPages:(NSArray*)pageModels {
    NSArray* productHeaders = [[pageModels.rac_sequence map:^NSString*(PageModel* page) {
        return page.title;
    }] array];
    
    // And gather the products by section
    //This does not filter products on multiple pages
    NSArray* productSections = @[];
    NSArray* panelItems = @[];
    NSArray* allItems = @[];
    for (NSArray* productModels in [pagesOfProducts objectEnumerator]) {
        NSArray* sortedFilteredProductModels = [SortsAndFilters
                                                sortAndFilterProductModels:productModels
                                                fromPageModels:pageModels];
        allItems = [allItems arrayByAddingObjectsFromArray:sortedFilteredProductModels];
    }
    
    NSPredicate* dedupePredicate = [SortsAndFilters filterDuplicateProductModels];
    NSArray* filteredItems = [allItems filteredArrayUsingPredicate:dedupePredicate];
    
    for (ProductGroupModel* product in filteredItems) {
        PagePanelItem* item = [[PagePanelItem alloc] init];
        item.item = product;
        item.itemType = PagePanelItemType_Product;
        panelItems = [panelItems arrayByAddingObject:item];
    }
    
    // Gather links by section
    NSArray* linkHeaders = @[];
    NSArray* linkSections = @[];
    for (PageModel* page in pageModels) {
        if ([page.elementModelsThatAreLinks count] > 0) {
            NSString* linkSection = [page.title stringByAppendingString:@" - Links"];
            linkHeaders = [linkHeaders arrayByAddingObject:linkSection];
            // Map the links in panel items.
            NSArray* items = @[];
            for (ElementModel* element in page.elementModelsThatAreLinks) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = element;
                
                switch (element.type) {
                    case ElementModelType_Link: {
                        ElementLinkModel* link = (ElementLinkModel*)element;
                        if (link.linkType == LinkTypeExternal) {
                            item.itemType = PagePanelItemType_LinkExternal;
                        } else {
                            item.itemType = PagePanelItemType_LinkInternal;
                        }
                        break;
                    }
                        
                    default: {
                        item.itemType = PagePanelItemType_Any;
                        NSLog(@"unhandled element panel type!");
                        break;
                    }
                }
                // SYN-1085
                // De-dupe non-product links
                BOOL isDupe = NO;
                ElementLinkModel* a = (ElementLinkModel*)element;
                for (PagePanelItem* bitem in items) {
                    ElementLinkModel* b = (ElementLinkModel*)bitem.item;
                    BOOL equalIDs = [a.ID isEqualToString:b.ID];
                    BOOL equalTitles = [a.linkTitle isEqualToString:b.linkTitle];
                    BOOL equalURLs = [a.URL isEqualTo:b.URL];
                    if (equalIDs || (equalTitles && equalURLs)) {
                        isDupe = YES;
                        break;
                    }
                }
                
                if (isDupe) {
                    NSLog(@"Caught a dupe link: %@ %@ %@",a.linkID,a.linkTitle,[a.URL asString]);
                } else {
                    // items = [items arrayByAddingObject:item];
                    panelItems = [panelItems arrayByAddingObject:item];
                }
            }
        }
    }
    
    
    
    
    productSections = [productSections arrayByAddingObject:panelItems];
    
    
    PagePanelState* productsPanel = [[PagePanelState alloc] init];
    productsPanel.sectionHeaderModels = productHeaders;
    productsPanel.itemsBySection = productSections;
    
    return productsPanel;
}

//+ (PagePanelState*)generateFilteredLinkPanelStateFromPages:(NSArray*)pageModels {
//   
//}

+ (PagePanelState*)generateFilteredVideoPanelStateFromPages:(NSArray*)pageModels {
    // Gather videos by section
    NSArray* videoHeaders = @[];
    NSArray* videoSections = @[];
    for (PageModel* page in pageModels) {
        if ([[page videoModels] count] > 0) {
            NSString* videoSection = [page.title stringByAppendingString:@" - Videos"];
            videoHeaders = [videoHeaders arrayByAddingObject:videoSection];
            // Map the videos in panel items.
            NSArray* items = @[];
            for (VideoModel* video in [page videoModels]) {
                PagePanelItem* item = [[PagePanelItem alloc] init];
                item.item = video;
                item.itemType = PagePanelItemType_Video;
                items = [items arrayByAddingObject:item];
            }
            videoSections = [videoSections arrayByAddingObject:items];
        }
    }
    PagePanelState* panelState = [[PagePanelState alloc] init];
    panelState.sectionHeaderModels = videoHeaders;
    panelState.itemsBySection = videoSections;
    return panelState;
}

+ (PagePanelState*)generatePagePanelStateFromProducts:(NSArray *)pagesOfProducts
                                             andPages:(NSArray *)pageModels {
    PagePanelState* products = [SortsAndFilters
                                generateProductPanelStateFromProducts:pagesOfProducts
                                andPages:pageModels];
    PagePanelState* links = [SortsAndFilters
                             generateLinkPanelStateFromPages:pageModels];
    
    PagePanelState* videos = [SortsAndFilters generateVideoPanelStateFromPages:pageModels];
    
    return [products pagePanelStateByAppending:[links pagePanelStateByAppending:videos]];
}

+ (PagePanelState*)generateFilteredPagePanelStateFromProducts:(NSArray *)pagesOfProducts andPages:(NSArray *)pageModels {
    PagePanelState* products = [SortsAndFilters
                                generateFilteredProductPanelStateFromProducts:pagesOfProducts
                                andPages:pageModels];
    
    return products;
}

+ (PagePanelState*)generatePagePanelStateAsVariantsWithProducts:(NSArray*)pagesOfProducts
                                                       andPages:(NSArray*)pageModels {
    NSArray* productHeaders = [[pageModels.rac_sequence map:^NSString*(PageModel* page) {
        return page.title;
    }] array];
    
    NSArray* toZip = @[pagesOfProducts.rac_sequence, pageModels.rac_sequence];
    NSArray* variantsByPage = [[RACSequence zip:toZip reduce:^NSArray* (NSArray* products, PageModel* page) {
        NSArray* elements = page.elementModels;
        return [[[elements.rac_sequence map:^PagePanelItem* (ElementModel* el) {
            
            PagePanelItem* item = [[PagePanelItem alloc] init];
            NSString* pId = el.productID;
            if (pId) {
                ProductGroupModel* pm = [products.rac_sequence foldLeftWithStart:nil reduce:^ProductGroupModel*(ProductGroupModel* acc, ProductGroupModel* val) {
                    if (acc) {
                        return acc;
                    }
                    
                    if ([val.ID isEqualToString:pId]) {
                        return val;
                    }
                    
                    return acc;
                }];
                
                if (pm) {
                    
                    if (el.type == ElementModelType_Variant) {
                        VariantModel* vm = [[VariantModel alloc] init];
                        vm.productGroup = pm;
                        vm.variantId = el.selectedVariant;
                        
                        item.item = vm;
                        item.itemType = PagePanelItemType_Variant;
                    } else {
                        item.item = pm;
                        item.itemType = PagePanelItemType_Product;
                    }
                    return item;
                }
                return nil;
            }
            return nil;
        }] filter:^BOOL(id value) {
            return value != nil;
        }] array];
    }] array];
    
    NSArray* zip = @[[pageModels.rac_sequence map:^NSArray*(PageModel* page) {
        return page.elementModels;
    }], variantsByPage.rac_sequence];
    
    variantsByPage = [[RACSequence zip:zip reduce:^NSArray* (NSArray* elements, NSArray* items) {
//        Filter out deplciate items
        NSPredicate* f = [SortsAndFilters filterDuplicatePagePanelItems];
        NSArray* a = [items filteredArrayUsingPredicate:f];
        
        NSComparator c = [SortsAndFilters
                          sortPagePanelItemsByYAxisUsingElementModels:elements];
        return [a sortedArrayUsingComparator:c];
    }] array];
    
    PagePanelState* links = [SortsAndFilters
                             generateLinkPanelStateFromPages:pageModels];
    PagePanelState* videos = [SortsAndFilters
                              generateVideoPanelStateFromPages:pageModels];
    
    PagePanelState* panelState = [[PagePanelState alloc] init];
    panelState.sectionHeaderModels = productHeaders;
    panelState.itemsBySection = variantsByPage;
    
    return [[panelState pagePanelStateByAppending:links] pagePanelStateByAppending:videos];
}

@end
