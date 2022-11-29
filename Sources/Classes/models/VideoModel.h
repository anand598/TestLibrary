//
//  VideoModel.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/24/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/ElementModel.h>

// Forward declartion because PageModel also references VideoModel.
@class PageModel;

/** A VideoModel is an object that contains all the info needed to prepare and play on-page and modal video. */
@interface VideoModel : SyndecaModel

/** The model of the page that contains this video. */
@property (readwrite) PageModel* page;
/** The model of the element that spawned this video. */
@property (readwrite) ElementModel* element;

/** The URL of the video stream. */
- (NSURL*)URL;
/** The URL of the thumbnail preview image. */
- (NSURL*)thumbURL;
/** The title of the video. */
- (NSString*)title;
/** The total width of the video. */
- (CGFloat)width;
/** The total height of the video. */
- (CGFloat)height;
/** The frame of the video in the page it was mapped to. */
- (CGRect)pageFrame;
/** Whether or not this video is meant for modal display only. */
- (BOOL)isModalOnly;
/** The media id of the widget. */
- (NSString*)mediaId;

- (BOOL)isAutoPlay;
- (BOOL)isLoopEnabled;
@end
