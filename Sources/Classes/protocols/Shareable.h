//
//  Shareable.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/4/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@class RACSignal;

typedef enum {
    ShareTypeUnknown,
    ShareTypeCatalog,
    ShareTypePage,
    ShareTypeSpread,
    ShareTypeProduct
} ShareType;

/** Some kind of shareable object. */
@protocol Shareable <NSObject>

/** Returns an array of ShareItems. Preferably three items to be exact.
 One of an image, one of a string and one of a URL. */
- (NSArray*)activityItems;

/** A signal that sends an image of the shareable. */
- (RACSignal*)imageForSharing;
/** Returns a description of the shareable given a certain activity. */
- (NSString*)textForSharingForActivity:(NSString*)a;
/** Returns a url for sharing. */
- (NSURL*)URLForSharing;
/** The type of thing that is being shared. */ 
- (ShareType)typeForSharing;

@end
