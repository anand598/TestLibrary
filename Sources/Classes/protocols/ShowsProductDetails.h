//
//  ShowsProductDetails.h
//  Nordstrom
//
//  Created by Schell Scivally on 7/28/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ProductDetailView.h>

/** Implementors can show and hide some kind of product details. */
@protocol ShowsProductDetails <NSObject>

/** Shows the details for a given product and calls the given block upon 
 completion */
- (void)showProductDetailsFor:(ProductGroupModel *)productModel
                   completion:(void (^)(BOOL finished))completion;
/** Shows the details for a given product. */
- (void)showProductDetailsFor:(ProductGroupModel*)productModel;
/** Hides a shown product detail thing. */
- (void)hideProductDetails;
/** Returns the product details view. */
- (ProductDetailView*)productDetailView;

@end
