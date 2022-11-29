//
//  AddToBagCart.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/17/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/HasID.h>

typedef id<HasID> (^ReadCartItem)(NSDictionary*);

@interface ShoppingCart : NSObject

@property (readwrite) BOOL isWishlist;

- (id)initWithSaveName:(NSString*)name andReader:(ReadCartItem)reader;

#pragma mark - Adding, removing and updating items.
- (void)addItem:(id<HasID>)item inQuantity:(NSUInteger)quantity;
- (void)removeItem:(id<HasID>)item;
- (void)updateItem:(id<HasID>)item toQuantity:(NSUInteger)quantity;
- (void)addItemsFromCart:(ShoppingCart*)cart;

#pragma mark - Querying the cart
- (NSUInteger)quantityOfItemWithID:(NSString*)ID;
- (NSUInteger)quantityOfItem:(id<HasID>)item;
- (NSUInteger)totalQuantityOfItems;
- (CGFloat)totalPrice;
- (NSString*)idString;
/** Returns all items (id<HasID>) in an array. */
- (NSArray*)array;
/** Reads a previously saved item store into memory, or a new blank item store 
 none exists on disk. 
 */
- (void)readItemStore;
/** Returns a boolean value if the item is currently in the favorites carts */
- (BOOL)itemIsFavorited:(id<HasID>)item;

#pragma mark - Properties
@property (readwrite) NSDictionary* itemStore;
/** The current running total quantity of items (not price). */
@property (readwrite) NSUInteger runningTotal;

@end
