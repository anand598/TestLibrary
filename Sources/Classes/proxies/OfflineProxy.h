//
//  OfflineProxy.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/29/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SyndecaSDK/SyndecaSDK.h>
#import <SyndecaSDK/OfflineCatalog.h>

@interface OfflineProxy : NSObject

+ (OfflineProxy*)sharedProxy;
+ (void)setSharedProxy:(OfflineProxy*)proxy;
+ (NSURL*)localURLForURL:(NSURL*)url;
+ (NSURL*)localURLForSavedImageNamed:(NSString*)name;
- (OfflineCatalog*)offlineCatalogWithIssueID:(NSString*)ID;
- (GuideModel*)offlineGuide;
- (RACSignal*)downloadIssue:(IssueModel*)issue;
- (void)deleteOfflineCatalogWithIssueID:(NSString*)ID;
- (RACSignal*)downloadImage:(NSURL*)url;

@property (readwrite) NSOperationQueue* operationQueue;
@property (readwrite) GuideModel* offlineGuide;
@property (readwrite) NSArray* offlineCatalogs;

@end
