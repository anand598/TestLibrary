//
//  ProductDetailViewDelegate.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ProductDetailViewResult.h>
#import <SyndecaSDK/ProductGroupModel.h>

//We must provide a class reference to the ProductDetailView here to prevent compiler warnings.
@class ProductDetailView;

/** Used to communicate between controllers that present ProductDetailView and the ProductDetailView itself. Allows adding to cart, saving favorite information, etc between all parts of the architecture */
@protocol ProductDetailViewDelegate <NSObject>

- (void)productDetailView:(ProductDetailView*)view didSelectResult:(ProductDetailViewResult*)result;
- (void)productDetailView:(ProductDetailView*)view didDeSelectResult:(ProductDetailViewResult*)result;
-(BOOL)checkIfCartContainsItem:(ProductGroupModel*)item;
-(void)updateHeartTabBarItem;
-(void)shouldRevealToggle;
-(id)senderDelegate;

@end
