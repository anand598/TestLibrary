//
//  SearchViewControllerDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 4/3/17.
//
//
#import <Foundation/Foundation.h>

/* Used to communicate through view controllers during a search event. Used by CatalogViewController, GuideViewController, and PublicationController to show and communicate with SearchViewController */
@protocol SearchViewControllerDelegate <NSObject>

- (void)showSearch:(id)sender;
- (void)cancelSearch:(id)sender;

@end
