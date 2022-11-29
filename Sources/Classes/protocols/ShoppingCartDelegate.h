//
//  ShoppingCartDelegate.h
//  Pods
//
//  Created by Schell Scivally on 4/27/16.
//
//

#import <Foundation/Foundation.h>

@class ShoppingCart;
@class ProductGroupModel;

@protocol ShoppingCartDelegate <NSObject>

- (void)didUpdateShoppingCart:(ShoppingCart*)shoppingCart;

-(void)didSelectProductForDetail:(ProductGroupModel*)product;

@end
