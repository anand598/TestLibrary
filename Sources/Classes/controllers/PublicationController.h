//
//  CatalogPhoneViewController.h
//  Syndeca iOS SDK
//
//  Created by Schell on 5/14/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/PageView.h>
#import <SyndecaSDK/PagePanelState.h>
#import <SyndecaSDK/ZoomRequestDelegate.h>
#import <SyndecaSDK/ElementSelectionDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/SearchViewControllerDelegate.h>
#import <SyndecaSDK/VerticalProductsHolderToggleDelegate.h>
#import <SyndecaSDK/RemovePanelItemDelegate.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

typedef enum {
    LeftButtonItemType_Back,
    LeftButtonItemType_Hamburger
} LeftButtonItemType;

/** The PublicationController displays the pages of a Syndeca publication. 
 The PublicationController can act as delegate and datasource for an external UITableView meant to display
 on-page elements. Indeed, this is what happens when used in conjuction with the CatalogViewController. */
@interface PublicationController : UICollectionViewController<UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, DependencyInjection, ItemSelectionDelegate, ElementSelectionDelegate, ZoomRequestDelegate, ElementSelectionDelegate, ProductDetailViewDelegate, SearchViewControllerDelegate, UITextFieldDelegate, RemovePanelItemDelegate> {
    CatalogModel* _catalogModel;
    PagePanelState* _elementPanelDataProvider;
}

/** The object to delegate user selections to. */
@property (readwrite) id<ItemSelectionDelegate> itemSelectionDelegate;
@property (readwrite) id<NSObject>backButtonDelegate;
@property (readwrite) LeftButtonItemType leftButtonItemType;
@property (readwrite) BOOL isShowingElementPanel;
@property (readwrite) BOOL shouldOpenProductsPanel;
@property (readwrite) UIBarButtonItem* pagesShareBarButtonItem;
@property (readwrite) UIBarButtonItem* toggleElementPanelButtonItem;
@property (readwrite) UIActivityViewController* shareViewController;
@property (readwrite) UIPopoverController* popOverController;
@property (readwrite) AVPlayerViewController* videoController;
@property (readwrite) VideoModel* videoModel;
@property (readwrite) UITableView* elementTableView;
@property (readwrite) UICollectionView* verticalElementCollectionView;
@property (readwrite) NSIndexPath* cellWithBorderPath;

#pragma mark - Getters
/** Returns the currently loaded CatalogModel or nil if no CatalogModel is loaded. */
- (CatalogModel*)catalogModel;
/** The current page's panel state. */
- (PagePanelState*)elementPanelDataProvider;
/** The leftmost visible PageView. */
- (PageView*)leftPageView;
/** The page models currently visible. */
- (NSArray*)visiblePageModels;
- (UIBarButtonItem*)backBarButtonItem;
- (UIBarButtonItem*)hamburgerBarButtonItem;
- (BOOL)hasVisibleOnPageElements;
#pragma mark - Displaying a Catalog
/** Sets the given CatalogModel and displays it by reloading the UI. */
- (void)setCatalogModel:(CatalogModel *)catalogModel;

#pragma mark - Page Navigation
/** Open the catalog to the given page. */
- (void)openPageWithIndexNumber:(NSNumber*)index;
/** Swipes to the next page. */
- (void)swipeToNext;

#pragma mark - Providing a UITableView for On-Page Elements 
- (void)setElementPanelTableView:(UITableView*)tableView;

#pragma mark - Providing a UICollection for On-Screen Elements in Vertical Layout
- (void)setVerticalElementPanelCollectionView:(UICollectionView*)collectionView;

#pragma mark - Other Updates
/** Updates the navigation toolbar items. */
- (void)setNavigationItems;

- (UIBarButtonItem*)newSearchItem;

/** The object to delegate possible user actions when the ProductDetailView is being displayed. */
@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;

@property (readwrite) id<SearchViewControllerDelegate> searchViewControllerDelegate;
@property (readwrite) id<NSObject> revealDelegate;

/** The delegate that allows toggle layout hidden when the pages view controller is scrolling */
@property (readwrite) id<VerticalProductsHolderToggleDelegate> verticalProductsHolderToggleDelegate;
/** The delegate that allows us to remove products with failing images */
@property (readwrite) id<RemovePanelItemDelegate> removePanelItemDelegate;

@end
