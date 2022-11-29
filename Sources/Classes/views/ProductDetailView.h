//
//  ProductDetailView.h
//  Syndeca iOS SDK
//
//  Created by Schell on 5/20/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/ShoppingCart.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/SwatchModel.h>


/** The ProductDetailView displays the details of a specific product. It is used by the ProductDetailViewController. */
@interface ProductDetailView : UIView<DependencyInjection, UICollectionViewDelegate, UICollectionViewDataSource> {
    ProductGroupModel* _productGroupModel;
}

#pragma mark - Recieving Notification of User Actions
@property (readwrite) id<ProductDetailViewDelegate> delegate;

#pragma mark - UI Elements
@property (readwrite) UIScrollView* scrollView;
@property (readwrite) UIView* contentView;
@property (readwrite) UICollectionView* previewImages;
@property (readwrite) UIPageControl* previewPageControl;
@property (readwrite) UILabel* titleLabel;
@property (readwrite) UILabel* priceLabel;
@property (readwrite) UILabel* saleLabel;
@property (readwrite) UILabel* auxPriceLabel;
@property (readwrite) UILabel* subtitleLabel;
@property (readwrite) UILabel* errorLabel;
@property (readwrite) UICollectionView* collectionViewSize;
@property (readwrite) UIView* sizesHolder;
@property (readwrite) UILabel* descriptionTitleLabel;
@property (readwrite) UILabel* descriptionLabel;
@property (readwrite) UILabel* featuresLabel;
@property (readwrite) UILabel* shippingTitleLabel;
@property (readwrite) UILabel* shippingDetailLabel;
@property (readwrite) UILabel* learnMoreLabel;
@property (readwrite) UILabel* swatchLabel;
@property (readwrite) UICollectionView* swatchImages;
@property (readwrite) UIButton* shopButton;
@property (readwrite) UIView* topBar;
@property (readwrite) UIView* midBar;
@property (readwrite) UIView* sizesBar;
@property (readwrite) UIView* detailsBar;
@property (readwrite) UIView* shippingBar;
@property (readwrite) UIView* btmBar;
@property (readwrite) UIButton* addToBagButton;
@property (readwrite) UIButton* addToWishlistButton;
@property (readwrite) CGFloat elementTableViewWidth;
@property (readwrite) CGFloat tabBarHeightAdjustment;

#pragma mark - Methods
/** Sets the ProductModel triggering a total view update. */
- (void)setProductGroupModel:(ProductGroupModel*)productGroupModel;
/** Selects the product variant at the given index. */
- (void)selectVariantAtIndex:(NSUInteger)index;
/** Update the product details to reflect the current ProductModel and selection. 
 This is automatically called after the ProductModel is set or a new selection is made.
 It is exposed here to aid with subclassing. */
- (void)onProductUpdate;
/** Returns a UICollectionViewCell suitable for displaying a SwatchModel.
 This is exposed here to aid with subclassing. */
- (UICollectionViewCell*)cellForSwatchImageAtIndexPath:(NSIndexPath*)indexPath;

#pragma mark - Getters
/** The currently loaded ProductModel or nil. */
- (ProductGroupModel*)productGroupModel;
/** The currently selected sub-product or nil. */
- (ProductEntityModel*)selectedProduct;
/** The index of the currently selected sub-product in its product group. */
- (NSUInteger)selectedProductIndex;
/** Product title text. */
- (NSAttributedString*)titleAttributedText;
/** Product subtitle text. */
- (NSAttributedString*)subtitleAttributedText;
/** Product price text. */
- (NSAttributedString*)priceAttributedText;
/** Product sale text. */
- (NSAttributedString*)saleAttributedText;
/** Product auxillary price text. */
- (NSAttributedString*)auxPriceAttributedText;
/** Product swatch title text. */
- (NSAttributedString*)swatchAttributedText;
/** Product description text. */
- (NSAttributedString*)descriptionAttributedText;
/** Product features text. */
- (NSAttributedString*)featuresAttributedText;
/** Items used to populate the swatch images UICollectionView. 
 This is exposed for subclassing. */
- (NSArray*)swatchImagesItems;
/** Items used to populate the preview images UICollectionView.
 This is exposed for subclassing. */
- (NSArray*)previewImagesItems;
/** Whether or not the product being displayed is considered "on sale". 
 Note: Maybe this should be moved to the ProductModel. */
- (BOOL)isSale;
- (SwatchModel*)selectedSwatch;


#pragma mark - Layout
/** The size to allow for the preview images. */
- (CGSize)sizeForPreviewImagesInsideSize:(CGSize)size;
/** The layout to apply to the preview images' collection view. */
- (UICollectionViewLayout*)previewImagesLayoutForSize:(CGSize)size;
/** The layout to apply to the swatch images' collection view. */
- (UICollectionViewLayout*)swatchImagesLayout;
/** Remake all UIView constraints.
 This is exposed for subclassing. */
- (void)makeLayoutForSize:(CGSize)size;
/** Format an internationalized currency string using an NSNumber. */
- (NSString*)currencyStringFrom:(NSNumber*)n;

#pragma mark - Buttons
- (void)didTapAddToWishlistButton:(id)tap;


@end
