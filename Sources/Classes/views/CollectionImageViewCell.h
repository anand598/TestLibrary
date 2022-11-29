//
//  CollectionReusableImageView.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

/** A collection cell view that includes an image, a label and an activity indicator. */
@interface CollectionImageViewCell : UICollectionViewCell

@property (readwrite) UIImageView* imageView;
@property (readwrite) UILabel* textLabel;
@property (readwrite) UILabel* subTextLabel;
@property (readwrite) UILabel* descriptionTextLabel;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) NSLayoutConstraint* imageViewHeight;

@end
