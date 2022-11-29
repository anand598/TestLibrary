//
//  AddToBagScreenView.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ShoppingCart.h>
#import <SyndecaSDK/ShoppingCartDelegate.h>
#import <SyndecaSDK/ShoppingCartItemDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>

@class RACSignal;


typedef void (^ExportCartAction) (ShoppingCart*);

@interface ShoppingCartScreenView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, ShoppingCartItemDelegate, ProductDetailViewDelegate>

@property (readwrite) id<ShoppingCartDelegate> shoppingCartDelegate;
/** property to hold the product detail view delegate*/
@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;

@property (readwrite) UILabel* titleLabel;
@property (readwrite) UILabel* productsHeader;
@property (readwrite) UILabel* qtyHeader;
@property (readwrite) UILabel* amountHeader;
@property (readwrite) UILabel* estTotalLabel;
@property (readwrite) UILabel* estTotalValue;
@property (readwrite) UILabel* emptyBagLabel;
@property (readwrite) UILabel* legalTextTitle;
@property (readwrite) UILabel* legalTextLabel;
@property (readwrite) UILabel* legalTextSub;
//@property (readwrite) UITableView* productsTableView;
@property (readwrite) UICollectionView* productsCollectionView;
@property (readwrite) UIButton* exportButton;
// Determines whether we track cart or wishlist events.
@property (readwrite) BOOL isWishlist;
@property (readwrite, copy) ExportCartAction exportAction;
@property (readwrite) ShoppingCart* shoppingCart;

- (RACSignal*)hasItems;
- (void)makeLayout;

@property (readwrite) BOOL willHaveTabBar;

@end
