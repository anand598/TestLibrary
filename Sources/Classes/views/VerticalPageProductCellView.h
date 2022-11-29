//
//  VerticalPageProductCellView.h
//  Pods
//
//  Created by Rijul Gupta on 6/27/17.
//
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaSDK.h>
#import <SyndecaSDK/PagePanelItem.h>
#import <SyndecaSDK/VerticalProductItemView.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/RemovePanelItemDelegate.h>

@interface VerticalPageProductCellView : UICollectionViewCell <DependencyInjection, RemovePanelItemDelegate>

/** Used as a UITableView identifying string :) */
+ (NSString*)identifier;
@property (readwrite) NSInteger* borderTag;

@property (readwrite) PagePanelItem* panelItem;
@property (readwrite) VerticalProductItemView* itemView;
//@property (readwrite) UIActivityIndicatorView* indicatorView;
/** A gradient layer for doing custom graphics and effects. */
//@property (readwrite) CAGradientLayer* gradientLayer;
-(void)toggleBorderShow;
-(void)toggleBorderHide;

@property (readwrite) id<RemovePanelItemDelegate> removePanelItemDelegate;
@end
