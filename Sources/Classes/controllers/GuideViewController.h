//
//  GuideViewController.h
//  Pods
//
//  Created by Schell Scivally on 4/11/16.
//
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/GuideModel.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/ProductDetailViewDelegate.h>
#import <SyndecaSDK/SearchViewControllerDelegate.h>
#import <SyndecaSDK/PublicationCollectionViewController.h>

typedef enum {
    GuideLayout_Automatic,
    GuideLayout_Grid,
    GuideLayout_Vertical
} GuideLayout;

/** The GuideViewController is the main controller for displaying the initial set of available publications to a user. */
@interface GuideViewController : UINavigationController <ItemSelectionDelegate, ProductDetailViewDelegate, SearchViewControllerDelegate, UITextFieldDelegate> {
    BOOL _isLoaded;
    BOOL _isLoading;
}

/** Determines the layout style of publications. */
@property (readwrite) GuideLayout guideLayout;
@property (readwrite) PublicationCollectionViewController* publicationsController;
/** The object to delegate publication selection to. */
@property (readwrite) id<ItemSelectionDelegate> itemSelectionDelegate;
/** The current GuideModel or nil. */
@property (readwrite) GuideModel* guideModel;
@property (readwrite) BOOL shouldShowVerticalPublicationsLayout;



/** Reloads the publications by fetching from the SyndecaAPI. */
- (void)reloadGuide;
/** Determines whether or not a GuideModel is loaded and being displayed. */
- (BOOL)isLoaded;
/** Determines whether or not the controller is fetching a GuideModel from the API. */
- (BOOL)isLoading;

/** property to hold the product detail view delegate*/
@property (readwrite) id<ProductDetailViewDelegate> productDetailViewDelegate;

@end
