//
//  UICollectionViewCell+UILabelContent.h
//  Pods
//
//  Created by Schell Scivally on 4/13/16.
//
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell (ContentViews)

#pragma mark - Creating Individual Views
/** Returns a configured UILabel that lives inside the UICollectionViewCell's contentView.
 If this function has been called before it will return a UILabel previously created, that is -
 once created it will always return the same view.
 */
- (UILabel*)contentViewLabelWithIdentifier:(NSString*)identifier;

/** Returns a configured UILabel that lives inside the UICollectionViewCell's contentView.
 If this function has been called before it will return a UILabel previously created, that is -
 once created it will always return the same view.
 */
- (UIImageView*)contentViewImageViewWithIdentifier:(NSString*)identifier;

/** Returns a configured UIActivityIndicatorView that lives inside the UICollectionViewCell's contentView.
 If this function has been called before it will return a UIActivityIndicatorView previously created, that is -
 once created it will always return the same view.
 */
- (UIActivityIndicatorView*)contentViewActivityIndicatorWithIdentifier:(NSString*)identifier;
//- (UIImageView*)contentViewActivityImageIndicatorWithIdentifier:(NSString*)identifier;

#pragma mark - Accessing Content Views Shorthand
/** Returns the content view with the given identifier. */
- (UIView*)contentViewWithIdentifier:(NSString*)identifier;

#pragma mark - Creating Multiple Views for Common Setups
/** Creates a UILabel, UIImageView and UIActivityIndicatorView that work in unison to display a titled image. 
 This is used for issue, page and thumbnail displays. 
 */
- (void)setupContentViewOfImageWithLabelId:(NSString*)labelId andImageViewId:(NSString*)imageViewId andActivityIndicator:(NSString*)indicatorId;

/** Creates a series of views to display search results for a particular item. Can be used for products, catalogs, external links, etc.
 */
- (void)setupContentViewOfSearchResultWithTitleLabelId:(NSString *)titleLabelId andImageViewId:(NSString *)imageViewId andActivityIndicatorId:(NSString *)indicatorId andSubtitleLabelId:(NSString *)subtitleLabelId andPriceId:(NSString *)priceId andSaleId:(NSString *)saleId andHeartViewId:(NSString *)heartViewId;

    
@end
