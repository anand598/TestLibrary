//
//  SearchNavigationController.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/24/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/SearchViewControllerDelegate.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/ProductDetailViewController.h>
#import <SyndecaSDK/Icons.h>
#import <SyndecaSDK/MasterConfiguration.h>
#import <SyndecaSDK/CatalogLinkDelegate.h>

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>


/** A controller for searching through a client's API data. */
@interface SearchViewController : UICollectionViewController <UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DependencyInjection>

@property (readwrite) NSArray* items;

@property (readwrite) id<ItemSelectionDelegate> itemSelectionDelegate;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) UITextField* searchField;
@property (readwrite) UIBarButtonItem* searchItem;
@property (readwrite) CatalogModel* catalog;
@property (readwrite) UILabel* resultsLabel;
@property (readwrite) UILabel* noResultsLabel;
@property (readwrite) NSArray* issueModels;
@property (readwrite) NSArray* catalogModels;

#pragma mark - Search

/** Conduct a new search. Returns true if the SearchViewController will handle displaying search results itself. */
- (bool)searchWithText:(NSString*)text inCatalog:(CatalogModel*)c;

/** property to hold the product detail view delegate*/
@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;

/** property to hold the search  view delegate*/
@property (readwrite) id<SearchViewControllerDelegate> searchViewControllerDelegate;

#pragma mark - Layout
- (UICollectionViewLayout*)collectionViewResultsLayout;
-(UICollectionViewCell*)configureSearchResultsCell:(UICollectionViewCell*)cell andIndexPath:(NSIndexPath*)indexPath;

- (NSString*)currencyStringFrom:(NSNumber*)n;
@end
