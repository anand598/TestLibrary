//
//  Overseer.h
//  Pods
//
//  Created by Schell Scivally on 2/29/16.
//
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/SyndecaConfig.h>
#import <SyndecaSDK/GuideModel.h>
#import <SyndecaSDK/GuideViewController.h>
#import <SyndecaSDK/CatalogViewController.h>
#import <SyndecaSDK/PageView.h>

@interface Overseer : NSObject

/** A SyndecaConfig for testing the SDK. */
+ (SyndecaConfig*)testConfig;

/** Selects the home screen from anywhere in the app. */
+ (void)selectHomeScreen;
/** The controller that lists all publications, aka the guide screen. */
+ (GuideViewController*)guideController;
/** The home screen's guide model. This is nil until the guide loads. */
+ (GuideModel*)guideModel;
/** Whether or not the guide model is loaded and the publication previews are displayed. */
+ (BOOL)guideIsLoaded;
/** Selects a publication in the guide screen. */
+ (void)selectPublication:(NSInteger)n;

/** Whether or not the publication is loaded and the publications's first page image is displayed. */
+ (BOOL)publicationIsLoaded;
/** The controller that displays a publication. */
+ (CatalogViewController*)catalogController;
/** The publication screen's model. This is nil until a publication is loaded. */
+ (CatalogModel*)catalogModel;

/** The page that is the current left most displayed in the publications view. */
+ (PageView*)currentPageView;

/** Selects a product in the publication screen. */
//+ (void)selectProduct:(NSInteger)n;
    
@end
