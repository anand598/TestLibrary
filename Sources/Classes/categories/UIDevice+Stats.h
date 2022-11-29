//
//  UIDevice+Stats.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/6/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Stats)

- (NSString*)batteryLevelStr;
- (NSString*)chargingStatus;
- (NSString*)appVersion;
- (NSString*)fullAppVersion;
- (NSString*)browser;
- (NSString*)availableMemory;
- (NSString*)diskSpace;

@end
