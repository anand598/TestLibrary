//
//  NSString+SyndecaAccessibility.m
//  The Catalogs
//
//  Created by Schell Scivally on 1/25/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "NSString+SyndecaAccessibility.h"

@implementation NSString (SyndecaAccessibility)

+ (NSString*)navigationToolBarLabel {
    return @"Navigation Toolbar";
}

+ (NSString*)navPanelLabel {
    return @"Navigation Panel";
}

+ (NSString*)navPanelContactLabel {
    return @"Navigation Panel / Contact Developer Button";
}

+ (NSString*)contactDeveloperFormLabel {
    return @"Contact Developer Form";
}

+ (NSString*)thumbnailPickerViewLabel {
    return @"Catalog / Page Picker";
}

+ (NSString*)guideCoverPickerViewLabel {
    return @"Guide / Catalog Picker";
}

+ (NSString*)guideFeaturedCatalogViewLabel {
    return @"Guide / Featured Catalog";
}

+ (NSString*)labelForProductWithName:(NSString*)name {
    return [NSString stringWithFormat:@"Product / %@",name];
}

+ (NSString*)catalogControllerViewLabel {
    return @"Catalog / View Screen";
}

+ (NSString*)catalogPagesPanelLabel {
    return @"Catalog / Page Views";
}

+ (NSString*)catalogNavPanelButtonLabel {
    return @"Catalog / Navigation Panel Button";
}

+ (NSString*)labelForCatalogWithTitle:(NSString*)title {
    return [title stringByAppendingFormat:@"Catalog / %@",title];
}

+ (NSString*)catalogProductsPanelLabel {
    return @"Catalog / Products Panel";
}

+ (NSString*)catalogSharalityPanelLabel {
    return @"Catalog / Sharality Panel";
}

+ (NSString*)catalogPopupProductViewLabel {
    return @"Catalog / Product Popup";
}

+ (NSString*)catalogThumbnailsButtonLabel {
    return @"Catalog / Table of Contents Button";
}

+ (NSString*)productDetailsShareButtonLabel {
    return @"Product Details / Share Button";
}

+ (NSString*)productDetailsSharalityPanelLabel {
    return @"Product Details / Sharality Panel";
}

+ (NSString*)productDetailsViewLabel {
    return @"Product Details / View";
}

+ (NSString*)productDetailsTitleViewLabel {
    return @"Product Details / Title";
}

+ (NSString*)productDetailsSubtitleViewLabel {
    return @"Product Details / Subtitle";
}

+ (NSString*)productDetailsDescriptionViewLabel {
    return @"Product Details / Description";
}

+ (NSString*)productDetailsContentViewLabel {
    return @"Product Details / Content";
}

+ (NSString*)productDetailsPreviewViewLabel {
    return @"Product Details / Preview";
}

+ (NSString*)productDetailsShopButtonLabel {
    return @"Product Details / Shop Now";
}

+ (NSString*)productDetailsShoppingCartLabel {
    return @"Product Details / Go to Shopping Cart";
}

+ (NSString*)productDetalsPriceLabel {
    return @"Product Details / Price";
}

+ (NSString*)catalogSharalityButtonLabel {
    return @"Catalog / Share Pages Button";
}

+ (NSString*)productDetailsPageControl {
    return @"Product Details / Page Indicator";
}

+ (NSString*)sharalityPanelButtonForSite:(NSString*)site {
    return [NSString stringWithFormat:@"Share on %@",site];
}

+ (NSString*)webShoppingCartViewLabel {
    return @"Web / Shopping Cart";
}

#pragma mark - Errors

+ (NSString*)offlineAlertLabel {
    return @"Network Offline Alert";
}

+ (NSString*)failedDownloadAlertLabel {
    return @"Download Failed Alert";
}

+ (NSString*)updatesAlertLabel {
    return @"Updates Available Alert";
}

@end

