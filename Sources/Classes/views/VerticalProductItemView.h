//
//  VerticalProductItemView.h
//  Pods
//
//  Created by Rijul Gupta on 6/29/17.
//
//
#import <UIKit/UIKit.h>
#import <SyndecaSDK/ElementLinkModel.h>
#import <SyndecaSDK/PagePanelItem.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/VideoModel.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/RemovePanelItemDelegate.h>
#import <AFNetworking/UIImageView+AFNetworking.h>


/** A ProductItemView displays an on-page element.
 The easiest way to display an on-page element is to retrieve its PagePanelItem from a PagePanelState
 and set it as this view's panelItem.
 */
@interface VerticalProductItemView : UIView  <DependencyInjection>

@property (readwrite) UIImageView* thumbView;
@property (readwrite) UIButton* heartView;
@property (readwrite) UILabel* heartLabel;
@property (readwrite) UIImageView* rightIconView;
@property (readwrite) UIButton* shopButton;

@property (readwrite) UILabel* titleView;
@property (readwrite) UILabel* subtitleView;
@property (readwrite) UILabel* priceView;
@property (readwrite) UILabel* priceViewStrike;
@property (readwrite) UILabel* saleView;
@property (readwrite) PagePanelItem* panelItem;
@property (readwrite) UICollectionView* swatchCollection;
@property (readwrite) NSArray* swatchItems;

@property (readwrite) UILabel* moreInfoLabel;

@property (readwrite) UIView* coverView;

- (void)configureForLink:(ElementLinkModel*)element;
- (void)configureForVideo:(VideoModel*)video;
- (void)configureForProduct:(ProductGroupModel*)product;
@property (readwrite) BOOL isSale;
@property (readwrite) id<RemovePanelItemDelegate> removePanelItemDelegate;

-(void)animateViewUnSelected;
- (void)animateViewSelected;
@end
