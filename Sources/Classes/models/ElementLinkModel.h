//
//  ElementLinkModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <SyndecaSDK/ElementModel.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/UrlModel.h>
#import <SyndecaSDK/SearchModel.h>

@interface ElementLinkModel : ElementModel<DependencyInjection>
/** An enumeration of link types. */
typedef enum {
    LinkTypeNone,
    LinkTypeInternal,
    LinkTypeExternal
} LinkType;

- (id)initWithSearchModel:(SearchModel*)model;

/** The link title. */
- (NSString*)linkID;
- (NSString*)linkTitle;
/** The link description. */
- (NSString*)linkDescription;
/** The url of the link.
 
 Returns nil if linkType is any type other than LinkTypeExternal.
 */
- (UrlModel*)URL;
- (void)setURL:(UrlModel*)URL;

/** The page of the link.
 
 Returns NSUIntegerMax if linkType is any type other than LinkTypeInternal.
 */
- (NSUInteger)page;

#pragma mark - Determining Content
/// @name Determining Content

/** The link type. */
- (LinkType)linkType;
/** Whether or not the link is a video. */
- (BOOL)isVideo;

@end
