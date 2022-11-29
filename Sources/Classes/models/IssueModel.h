//
//  IssueModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/GuideModel.h>
#import <SyndecaSDK/DependencyInjection.h>

@interface IssueModel : SyndecaModel <DependencyInjection>
/** The parent guide model. */
@property (readwrite) GuideModel* guide;
/** Whether or not to access out-of-guide issues. */
@property (readwrite) BOOL accessOutOfGuide;
/** The title of the issue. */
- (NSString*)title;
/** Whether or not this is a featured issue. */
- (BOOL)isFeatured;
/** The build number of this issue. API1 only. */
- (NSString*)buildNum;
/** A list of URLs of thumb cover images, keyed by resolution. */
- (NSDictionary*)thumbURLs;
/** A list of URLs of full size cover images, keyed by resolution. */
- (NSDictionary*)imageURLs;
/** An integer specifying the issue's sort order. */
- (NSUInteger)sortOrder;
/** The URL for the cover thumbnail in a given resolution. */
- (NSURL*)thumbURLForResolution:(NSString*)resolution;
/** The URL for the cover image in a given resolution. */
- (NSURL*)imageURLForResolution:(NSString *)resolution;
/** The URL for the cover image using an educated guess of size based on device resolution. */
- (NSURL*)coverURL;

- (NSInteger)roughFileSizeInBytes;

- (NSString*)key;

- (NSUInteger)numberId;

@end
