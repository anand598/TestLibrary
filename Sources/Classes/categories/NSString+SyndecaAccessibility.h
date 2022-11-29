//
//  NSString+SyndecaAccessibility.h
//  The Catalogs
//
//  Created by Schell Scivally on 1/25/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Accesibility labels for various views. */
@interface NSString (SyndecaAccessibility)

+ (NSString*)navigationToolBarLabel;
+ (NSString*)navPanelLabel;
+ (NSString*)contactDeveloperFormLabel;
+ (NSString*)navPanelContactLabel;
+ (NSString*)guideCoverPickerViewLabel;
+ (NSString*)guideFeaturedCatalogViewLabel;
+ (NSString*)catalogControllerViewLabel;
+ (NSString*)catalogPagesPanelLabel;
+ (NSString*)catalogProductsPanelLabel;
+ (NSString*)catalogSharalityButtonLabel;
+ (NSString*)catalogSharalityPanelLabel;
+ (NSString*)catalogPopupProductViewLabel;
+ (NSString*)catalogNavPanelButtonLabel;
+ (NSString*)catalogThumbnailsButtonLabel;
+ (NSString*)sharalityPanelButtonForSite:(NSString*)site;
+ (NSString*)thumbnailPickerViewLabel;
+ (NSString*)productDetailsViewLabel;
+ (NSString*)productDetailsTitleViewLabel;
+ (NSString*)productDetailsSubtitleViewLabel;
+ (NSString*)productDetailsDescriptionViewLabel;
+ (NSString*)productDetailsContentViewLabel;
+ (NSString*)productDetailsPreviewViewLabel;
+ (NSString*)productDetalsPriceLabel;
+ (NSString*)productDetailsShoppingCartLabel;
+ (NSString*)productDetailsShopButtonLabel;
+ (NSString*)productDetailsShareButtonLabel;
+ (NSString*)productDetailsSharalityPanelLabel;
+ (NSString*)productDetailsPageControl;
+ (NSString*)webShoppingCartViewLabel;
+ (NSString*)labelForCatalogWithTitle:(NSString*)title;
+ (NSString*)labelForProductWithName:(NSString*)name;

#pragma mark - Error Popups

+ (NSString*)offlineAlertLabel;
+ (NSString*)failedDownloadAlertLabel;

#pragma mark - Notifications

+ (NSString*)updatesAlertLabel;

@end
