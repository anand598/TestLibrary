//
//  TOCScreenController.h
//  Syndeca iOS SDK
//
//  Created by Schell on 4/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaSDK.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/PageModel.h>

/** The TOCController
 Uses an IssueModel for TOC.
 */
@interface TOCController : UINavigationController <ItemSelectionDelegate> 

/** The object to delegate page selections to. */
@property (readwrite) id<ItemSelectionDelegate> itemSelectionDelegate;

/** The cache of image urls and images, we don't load images more than once **/
@property (readwrite) NSCache* imageCache;

/** Updates the toc with a new list of pages, allowing it to display.*/
- (void)loadPages:(NSArray*)pageModels;
/** Shows a certain page. */
- (void)showPageWithModel:(PageModel*)pm;

@end
