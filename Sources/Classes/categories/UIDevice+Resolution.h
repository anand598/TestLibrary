//
//  UIDevice+Resolution.h
//  CocoaViewer
//
//  Created by Schell Scivally on 4/5/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIDevicePlatformMajor_Phone,
    UIDevicePlatformMajor_Pad,
    UIDevicePlatformMajor_Simulator,
    UIDevicePlatformMajor_None
} UIDevicePlatformMajor;

@interface UIDevice (Resolution)
/** Returns the major version of the device platform. */
- (UIDevicePlatformMajor)platformMajor;
/** Returns a string representing the hardware platform. */
- (NSString*)platform;
/** Returns a string representing the hardware resolution */
- (NSString*)resolution;
/** Returns a list of supported resolutions ordered from highest to lowest. */
- (NSArray*)listOfSupportedResolutions;
/** Returns the ios version. */
- (NSString*)osVersionBuild;
/** Returns a numerical screen resolution. */
- (CGSize)screenSize;
/** Whether or not the device is a simulator. */
- (BOOL)isSimulator;

@end
