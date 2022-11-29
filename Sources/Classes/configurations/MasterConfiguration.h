//
//  MasterConfiguration.h
//  Syndeca iOS SDK
//
//  Created by Schell on 5/12/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SyndecaSDK/ProductDetailView.h>
#import <SyndecaSDK/PagePanelState.h>
#import <SyndecaSDK/ProductItemView.h>
#import <SyndecaSDK/SyndecaConfig.h>

@class ProductCellView;

typedef PagePanelState* (^ProductPanelStateGenerator)(NSArray* productsByPage, NSArray* pageModels);
typedef void (^ProductDetailShopNowAction)(ProductDetailView* detailView);
typedef void (^ProductDetailAltShareAction)(ProductDetailView* detailView, NSURL* shareURL);
typedef UITableViewCell* (^HamburgerMenuCellDecorator)(UITableView* tableView, NSIndexPath* indexPath, UITableViewCell* cell);

/** A class we can use to store app wide configuration values. As we customize
 the look and feel of our apps this class should try to consolidate as many of 
 those customizations as possible. That way making a new app could be as easy 
 as replacing values in this config class.
 */
@interface MasterConfiguration : NSObject <DependencyInjection>

#pragma mark - Utilities for Configuration
/** Returns the first item that is not nil. */
+ (id)choose:(id)item1 or:(id)item2;
+ (id)choose:(id)item1 or:(id)item2 or:(id)item3;
/** Constrains the label's size */
//+ (CGRect)constrainLabel:(UILabel*)label withinFrame:(CGRect)frame;

#pragma mark - General Use
+ (MasterConfiguration*)sharedConfiguration;
+ (void)setSharedConfiguration:(MasterConfiguration*)config;

#pragma mark - Client Info
@property (readwrite) NSString* clientName;
@property (readwrite) NSString* clientFeedbackEmail;
@property (readwrite) NSString* clientFeedbackEmailSubject;

#pragma mark - Syndeca Configuration
@property (readwrite, copy) SyndecaConfig* (^syndecaSDKConfig)(void);

#pragma mark - Colors
- (UIColor*)tabBarTintColor;
- (UIColor*)cancelButtonColor;
- (UIColor*)scanShopResultsTitleViewLabelColor;


#pragma mark - Toolbar
/** The logo shown in the toolbar at the top of most screens. */
@property (readwrite) UIImage* toolbarLogo;
/** The logo bar button item. */
@property (readwrite) UIBarButtonItem* toolbarLogoItem;
@property (readwrite) UIView* toolbarLogoView;
/** The initial items in the toolbar at the top of most screens. */
@property (readwrite) NSArray* toolbarItems;

#pragma mark - Tab Bar 
/** The image to use for the bag icon. */
@property (readwrite) UIImage* bagIcon;
@property (readwrite) NSString* bagName;

#pragma mark - Navigation Bar
/** The image view used for most controller's navigationBar.titleView property. */
- (UIView*)navigationBarTitleView;

#pragma mark- Catalog
@property (readwrite) BOOL catalogHasSearch;
@property (readwrite) BOOL skipToFeaturedCatalog;

#pragma mark - Table of Contents
/** The background color of the table of contents scrollview. */
@property (readwrite) UIColor* tocBackgroundColor;
/** The text color for the page labels in the table of contents. */
@property (readwrite) UIColor* tocPageLabelColor;
/** The background color to use for highlighting a given page. */
@property (readwrite) UIColor* tocPageHighlightColor;

#pragma mark - Cart/Bag
/** The url to load by default when a user taps the cart/bag icon in the tab 
 bar. */
@property (readwrite) NSURL* phoneBagUrl;
@property (readwrite) NSURL* padBagUrl;
@property (readwrite) UIEdgeInsets webViewInsets;

#pragma mark - Product Details
@property (readwrite, copy) ProductDetailShopNowAction shopNowAction;
@property (readwrite, copy) ProductDetailAltShareAction alternativeShareAction;
@property (readwrite) UIColor* productDetailShopNowButtonColor;
@property (readwrite) NSString* productDetailShopNowText;
@property (readwrite) BOOL shouldShowWebPDP;

#pragma mark - Product Panel (iPad)
@property (readwrite) CGFloat productPanelPadding;
@property (readwrite) UIColor* productPanelBackgroundColor;
@property (readwrite) UIColor* toggleVerticalProductsLabelColor;
@property (readwrite) UIColor* toggleVerticalProductsBackgroundColor;
@property (readwrite) UIColor* productPanelSeparatorColor;
@property (readwrite) UIEdgeInsets productPanelContentInset;
@property (readwrite) CGFloat productCellWidth;
@property (readwrite) CGFloat productCellHeight;
@property (readwrite) UIViewContentMode productCellImageContentMode;
@property (readwrite, copy) ProductPanelStateGenerator generatePagePanelState;
@property (readwrite, copy) ProductPanelStateGenerator generateFilteredPagePanelState;
@property (readwrite) NSTextAlignment productCellTitleAlignment;
@property (readwrite) UIColor* productCellTitleTextColor;
@property (readwrite) UIColor* productCellTitleTextHighlightColor;
@property (readwrite) NSUInteger productItemSubtitleNumLines;
@property (readwrite) UIColor* productCellTopBackgroundColor;
@property (readwrite) UIColor* productCellTopBorderColor;
@property (readwrite) UIColor* productCellBottomBackgroundColor;
@property (readwrite) UIColor* productCellHighlightTopBackgroundColor;
@property (readwrite) UIColor* productCellHighlightTopBorderColor;
@property (readwrite) UIColor* productCellHighlightBottomBackgroundColor;

#pragma mark - Sharing
@property (readwrite) NSString* emailShareSubject;
@property (readwrite) NSDictionary* shareTypeToShareKey;
- (NSString*)changeShareTypeToShareKey:(NSString*)type;

#pragma mark - Scan
@property (readwrite) NSString* snapPhotoDialogue1;
@property (readwrite) NSString* snapPhotoDialogue2;
@property (readwrite) CGFloat scanRate;
@property (readwrite) BOOL shouldShowContinuousScan;
@property (readwrite) CGFloat interstitialTimeToShow;
@property (readwrite) CGFloat interstitialTimeToHide;
@property (readwrite) UIFont* scanInterstitialLabelFont;
@property (readwrite) UIFont* scanInterstitialLabelFontiPad;

#pragma mark - Banner and GuideView

@property (readwrite) CGFloat iPhoneBannerImageHeight;
@property (readwrite) CGFloat iPadBannerImageHeight;
@property (readwrite) CGFloat iPhoneBannerImageTop;
@property (readwrite) CGFloat iPadBannerImageTop;
@property (readwrite) CGFloat verticalPublicationsLayoutHeightOffset;


#pragma mark
@property (readwrite) BOOL isShopCatalogs;


@property (readwrite) WKProcessPool* globalProcessPool;

- (void)configureProductPanelValues;
@end
