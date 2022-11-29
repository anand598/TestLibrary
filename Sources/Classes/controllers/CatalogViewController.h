//
//  CatalogViewController.h
//  Pods
//
//  Created by Schell Scivally on 4/7/16.
//
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/SearchViewControllerDelegate.h>
#import <SyndecaSDK/VerticalProductsHolderToggleDelegate.h>
#import <SyndecaSDK/PageView.h>
#import <SyndecaSDK/CatalogLinkDelegate.h>
#import <SyndecaSDK/PublicationController.h>

/** 
 The CatalogViewController is responsible for displaying a publication on both iPhone and iPad.It also displays product details when a user selects a product.
 
 -Contains the used PagesViewController and handles scrolling logic.
 -Contains VerticalProductHolder toggle delegate, which allows the holder view toggle function to respond to the pages view controller scrollview delegate functions.
 */
@interface CatalogViewController : UINavigationController <ItemSelectionDelegate, ProductDetailViewDelegate, SearchViewControllerDelegate, VerticalProductsHolderToggleDelegate, UIGestureRecognizerDelegate> {
    CatalogModel* _catalogModel;
}

/** The object to delegate possible user actions when the ProductDetailView is being displayed. */
@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;
/** The object to delegate links to other catalogs. */
@property (readwrite) id<CatalogLinkDelegate> catalogLinkDelegate;
@property (readwrite) PublicationController* pagesController;

- (void)setHasOnPageElementPanel:(BOOL)hasPanel;
/** Loads a new publication (CatalogModel) from the API given an IssueModel. */
- (void)loadIssueWithModel:(IssueModel*)issueModel onComplete:(void (^)(CatalogModel* catalog))complete;
/** Loads a new publication (CatalogModel) from the API given an IssueModel. 
 This is a blockless alias of loadIssueWithMode:onComplete:
 */
- (void)loadIssueWithModel:(IssueModel*)issueModel;
/** Displays a publication without fetching from the API. */
- (void)setCatalogModel:(CatalogModel*)catalogModel;
/** Returns the currently loaded CatalogModel, or nil. */
- (CatalogModel*)catalogModel;
/** Returns the leftmost visible PageView. */
- (PageView*)leftPageView;
/** The page models of the pages that are currently visible */
- (NSArray*)visiblePageModels;
/** Opens the current publication to the page with the given index. */
- (void)openPage:(NSUInteger)pageIndex;
- (IBAction)handleVerticalProductHolderPan:(UIPanGestureRecognizer *)recognizer;
- (UITabBarItem*)pageTabBarItem;
- (UITabBarItem*)homeTabBarItem;
@end
