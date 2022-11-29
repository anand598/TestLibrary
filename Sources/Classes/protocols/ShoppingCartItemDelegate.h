//
//  ShoppingCartItemDelegate.h
//  Pods
//
//  Created by Schell Scivally on 5/16/16.
//
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/HasID.h>

@protocol ShoppingCartItemDelegate <NSObject>
- (void)shoppingCartItem:(id<HasID>)item updatedQuantityTo:(NSUInteger)quantity;
@end
