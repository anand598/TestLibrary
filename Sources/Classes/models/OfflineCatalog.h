//
//  OfflineCatalog.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/IssueModel.h>
#import <SyndecaSDK/CatalogModel.h>

@interface OfflineCatalog : NSObject

+ (NSURL*)offlineDataURL;
+ (NSURL*)offlineImagesURL;
- (id)initWithContentsOfURL:(NSURL*)url;
- (BOOL)writeToDisk;
- (NSDictionary*)info;
- (NSURL*)localURL;
- (NSArray*)allImageURLs;

@property IssueModel* issueModel;
@property CatalogModel* catalogModel;
@property NSArray* products;

@end
