//
//  ProductDetailViewController.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/PageModel.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/VariantModel.h>
#import <SyndecaSDK/ProductDetailView.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/ShoppingCartController.h>
#import <MessageUI/MessageUI.h>


/** A UIViewController capable of displaying product details. */
@interface ProductDetailViewController : UIViewController <UIPopoverControllerDelegate, ProductDetailViewDelegate, MFMailComposeViewControllerDelegate>

@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;
@property (readwrite) MFMailComposeViewController* mailController;
@property (readwrite) BOOL isFromSearchController;


#pragma mark - Creation
/** Initialize with a PageModel and ProductModel. */
- (id)initWithPageModel:(PageModel*)pageModel andProductGroupModel:(ProductGroupModel*)productGroupModel;

/** Initialize with a PageModel, ProductGroupModel and VariantModel.
 When the view appears, any selection based on variant will be pre-selected. */
- (id)initWithPageModel:(PageModel*)pageModel andProductGroupModel:(ProductGroupModel*)productGroupModel andVariantModel:(VariantModel*)variantModel;

/** Reloads the detail view using a new product model, and selects the variant at the given index. */
- (void)reloadDetailViewWithProductGroupModel:(ProductGroupModel*)productGroupModel andVariantIndex:(NSUInteger)ndx;

#pragma mark - Getting the Details View
- (ProductDetailView*)detailView;

#pragma mark - Heart/Favoriting
- (void)heartProduct;
- (void)updateHeartTabBarItem;
#pragma mark Factories
- (ShoppingCartController*)newWishlistController;
    
@end
