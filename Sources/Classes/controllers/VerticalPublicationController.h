//
//  VerticalPublicationController.h
//  Pods
//
//  Created by Rijul Gupta on 6/26/17.
//
//

#import <UIKit/UIKit.h>

#import <SyndecaSDK/CatalogModel.h>


@interface VerticalPublicationController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    CatalogModel* _catalogModel;
}


@property (readwrite) UIActivityIndicatorView* indicatorView;

#pragma mark - Getters
/** Returns the currently loaded CatalogModel or nil if no CatalogModel is loaded. */
- (CatalogModel*)catalogModel;

#pragma mark - Displaying a Catalog
/** Sets the given CatalogModel and displays it by reloading the UI. */
- (void)setCatalogModel:(CatalogModel *)catalogModel;

@end
