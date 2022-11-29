//
//  GuideModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/DependencyInjection.h>

@class IssueModel;

@interface GuideModel : SyndecaModel<DependencyInjection>

/** The external Syndeca Service Platform version. */
- (NSString*)platformVersion;
/** The issues listed in this guide.
 
 Returns an array of JSONGuideIssueModels.
 */
- (NSArray*)issueModels;
/** The itunes AppStore update URL. */
- (NSURL*)updateURL;
/** Info about each newer app version. If no newer versions exist this property
 will be nil. 
 */
- (NSArray*)newerAppVersions;


#pragma mark - Equality
/** Returns YES if the guide model given is the same version as this. */
- (BOOL)isSameVersionAsGuideModel:(GuideModel*)guideModel;

#pragma mark - Common ops

- (IssueModel*)issueWithID:(NSString*)ID;

// SYN-1544
// Use new Company Logo field from API
- (NSURL*)logoURL;

@end
