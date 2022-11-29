//
//  VerticalPageTableViewCell.h
//  Pods
//
//  Created by Rijul Gupta on 6/27/17.
//
//


#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaSDK.h>

@interface VerticalPageTableViewCell : UITableViewCell

/** Used as a UITableView identifying string :) */
+ (NSString*)identifier;

@property (readwrite) UIImageView* pageImageView;
//@property (readwrite) UIActivityIndicatorView* indicatorView;
/** A gradient layer for doing custom graphics and effects. */
//@property (readwrite) CAGradientLayer* gradientLayer;

@end

