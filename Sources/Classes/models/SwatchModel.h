//
//  SwatchModel.h
//  Syndeca iOS SDK
//
//  Created by Schell on 5/15/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

/** A simplified model for displaying swatches. */
@interface SwatchModel : NSObject

@property (readwrite) NSString* name;
@property (readwrite) NSString* familyName;
@property (readwrite) NSURL* imageURL;
@property (readwrite) NSURL* zoomURL;

@end
