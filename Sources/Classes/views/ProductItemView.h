//
//  PolyProductItemVIew.h
//  Syndeca iOS SDK
//
//  Created by Schell on 5/15/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ElementLinkModel.h>
#import <SyndecaSDK/PagePanelItem.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/VideoModel.h>

/** A ProductItemView displays an on-page element.
 The easiest way to display an on-page element is to retrieve its PagePanelItem from a PagePanelState
 and set it as this view's panelItem.
 */
@interface ProductItemView : UIView

@property (readwrite) UIImageView* thumbView;
@property (readwrite) UIView* thumbHolderView;
@property (readwrite) UIButton* heartView;
@property (readwrite) UILabel* heartLabel;
@property (readwrite) UIImageView* rightIconView;
@property (readwrite) UIButton* shopButton;

@property (readwrite) UILabel* titleView;
@property (readwrite) UILabel* subtitleView;
@property (readwrite) UILabel* priceView;
@property (readwrite) UILabel* saleView;
@property (readwrite) PagePanelItem* panelItem;
@property (readwrite) UICollectionView* swatchCollection;
@property (readwrite) NSArray* swatchItems;

@property (readwrite) UILabel* moreInfoLabel;

@property (readwrite) UIView* coverView;

- (void)configureForLink:(ElementLinkModel*)element;
- (void)configureForVideo:(VideoModel*)video;
- (void)configureForProduct:(ProductGroupModel*)product;

-(void)animateViewUnSelected;
- (void)animateViewSelected;


@end
