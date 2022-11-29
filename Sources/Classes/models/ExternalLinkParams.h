//
//  ExternalLinkParams.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/2/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

/** A helper class that takes care of sanitizing external links with tracking
 parameters, etc. 
 @see https://synapsegroup.jira.com/wiki/display/SGI/bebe+tracking+updates
 */
@interface ExternalLinkParams : NSObject

/** An app-wide singleton instance. */
+ (ExternalLinkParams*)sharedParams;
+ (void)setSharedParams:(ExternalLinkParams*)shared;
/** Returns the query key value pairs of a NSURL* as a NSDictionary* */
+ (NSDictionary*)queryInfoWithURL:(NSURL*)url;
/** Returns a key-value encoded string from the given NSDictionary */
+ (NSString*)queryStringFromInfo:(NSDictionary*)info;
/** Merges the key-values of two dictionaries. */
+ (NSDictionary*)merge:(NSDictionary*)override with:(NSDictionary*)base;
/** Replaces the parameters in the given url with the given params. */
+ (NSURL*)replaceParams:(NSDictionary*)params inURL:(NSURL*)URL;

/** Appends the parameters to the given link. */
+ (NSURL*)appendParams:(NSDictionary*)params toURL:(NSURL*)URL;
/** Appends self.params to the given link. 
 This is a specialization of appendParams:toURL:
 */
- (NSURL*)appendParamsToURL:(NSURL*)url;

/** A dictionary of key-value pairs to be appended onto outgoing links. */
@property (readwrite) NSDictionary* params;

@end
