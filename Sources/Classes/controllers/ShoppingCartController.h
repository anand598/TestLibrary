//
//  AddToBagScreenController.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ShoppingCartScreenView.h>
#import <SyndecaSDK/ShoppingCart.h>
#import <SyndecaSDK/ShoppingCartDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>

@interface ShoppingCartController : UIViewController <UITextFieldDelegate, UICollectionViewDelegateFlowLayout, ShoppingCartDelegate, ProductDetailViewDelegate>

@property (readwrite) ShoppingCartScreenView* shoppingCartScreen;

@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) UITextField* searchField;
@property (readwrite) UIBarButtonItem* searchItem;
@property (readwrite) CatalogModel* catalog;
@property (readwrite) UILabel* resultsLabel;

/*This property allows you to override the hmaburger menu button and show a back button. Only set this to true if you are presenting this as a view controller from some other view in your app heirarchy**/
@property (readwrite) BOOL shouldShowBackButton;

@property (readwrite) BOOL willHaveTabBar;
@property (readwrite) id<NSObject> revealDelegate;


@end
