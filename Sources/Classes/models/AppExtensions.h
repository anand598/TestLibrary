//
//  AppExtensions.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 3/6/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

/** A set of extensions that the app supports */
@interface AppExtensions : NSObject

@property (readwrite) BOOL sharingEnabled;
@property (readwrite) BOOL searchEnabled;
@property (readwrite) BOOL tocEnabled;
@property (readwrite) BOOL shoppingEnabled;
/** Whether or not to use single pages. */
@property (readwrite) BOOL usesSinglePages;
/** Whether or not to display the catalog with front and back covers. */
@property (readwrite) BOOL hasCover;

@end
