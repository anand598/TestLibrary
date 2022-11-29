//
//  ProductCellView.h
//  Syndeca iOS SDK
//
//  Created by Schell on 6/5/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaSDK.h>
#import <SyndecaSDK/PagePanelItem.h>
#import <SyndecaSDK/ProductItemView.h>

@interface ProductCellView : UITableViewCell

/** Used as a UITableView identifying string :) */
+ (NSString*)identifier;

@property (readwrite) PagePanelItem* panelItem;
@property (readwrite) ProductItemView* itemView;
//@property (readwrite) UIActivityIndicatorView* indicatorView;
/** A gradient layer for doing custom graphics and effects. */
//@property (readwrite) CAGradientLayer* gradientLayer;

@end
