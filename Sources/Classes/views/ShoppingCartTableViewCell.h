//
//  AddToBagTableViewCell.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <SyndecaSDK/ShoppingCartItemDelegate.h>

@interface ShoppingCartTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (readwrite) id<ShoppingCartItemDelegate> shoppingCartItemDelegate;
@property (readwrite) ProductGroupModel* productModel;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) CGFloat quantity;
@property (readwrite) UITextField* quantityField;
@property (readwrite) UIButton* quantityDone;
@property (readwrite) UILabel* amountLabel;

+ (NSString*)cellIdentifier;
+ (CGFloat)quantityOffsetInView:(UIView*)view;
+ (CGFloat)amountOffsetInView:(UIView*)view;

@end
