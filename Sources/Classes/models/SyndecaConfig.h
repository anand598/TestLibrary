//
//  SyndecaConfig.h
//  CocoaViewer
//
//  Created by Schell Scivally on 11/20/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_STAGING NO // Change this out when the client requests a staging build.

#ifdef DEBUG
    #define IS_DEBUG YES
    #define IS_BETA NO
    #define IS_PRODUCTION NO
#elif BETA
    #define IS_DEBUG YES
    #define IS_BETA YES
    #define IS_PRODUCTION NO
#else
    #define IS_DEBUG NO
    #define IS_BETA NO
    #define IS_STAGING NO // This way we can never send out a staging build to production.
    #define IS_PRODUCTION YES
#endif

#define IS_DEBUG_ONLY (IS_DEBUG && !IS_BETA && !IS_PRODUCTION)

@interface SyndecaConfig : NSObject

#pragma mark - Creating Config Objects

@property (readwrite) NSString* productionAPI;
@property (readwrite) NSString* stagingAPI;
@property (readwrite) NSString* shareAPI;
@property (readwrite) NSString* trackAPI;
@property (readwrite) NSString* guideKey;
@property (readwrite) BOOL isDebug;
@property (readwrite) BOOL isArchive;
@property (readwrite) BOOL isStaging;
@property (readwrite) BOOL usesCDN;

#pragma mark - Cloning
// A convenience method for cloning a configuration.
- (SyndecaConfig*)clone;

#pragma mark - Getting Config Settings
/** The location of the syndeca service being used. This is either productionAPI or stagingAPI. */
- (NSString*)syndecaAPI;

@end
