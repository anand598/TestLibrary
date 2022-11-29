//
//  VerticalPageView.h
//  Pods
//
//  Created by Rijul Gupta on 6/27/17.
//
//
#import <UIKit/UIKit.h>
#import <SyndecaSDK/PagePanelState.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/PageModel.h>
#import <SyndecaSDK/PageView.h>
#import <SyndecaSDK/ItemSelection.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/ElementSelectionDelegate.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/ZoomRequestDelegate.h>

/** An item view for the ItemScrollView in a PolyCatalogScreenView. */
@interface VerticalPageView : UIView<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ElementSelectionDelegate>

- (id)initWithFrame:(CGRect)frame andZoomContainer:(UIView*)view;

#pragma mark - Properties

@property (readwrite) CatalogModel* catalogModel;
@property (readwrite) PageModel* pageModel;
@property (readwrite) PageView* pageView;
@property (readwrite) UIView* pageViewMask;
@property (readwrite) UIScrollView* scrollView;
/** An adjustment to the content size to allow space for things like a tab bar in a parent view. */
@property (readwrite) CGFloat contentSizeHeightAdjustment;
@property (readwrite) id<ItemSelectionDelegate> delegate;
@property (readwrite) id<ElementSelectionDelegate> elementSelectionDelegate;

@property (readwrite) id<ZoomRequestDelegate> zoomDelegate;

- (void)updateLayout;

#pragma mark - Helpers
@property (readwrite) PagePanelState* elementTableDataProvider;

#pragma mark - Controlling video
/** Pauses all video on the page. */
- (void)pauseAllVideos;

@end
