//
//  ShareProxy.h
//  Syndeca iOS SDK
//
//  Created by Schell on 6/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
//#import "ProductGroupModel.h"
#import <SyndecaSDK/ProductEntityModel.h>
#import <SyndecaSDK/Shareable.h>


@interface ShareProxy : NSObject

@property (readwrite) UIActivityViewController* shareController;
@property (readwrite) ShareType lastShareType;
@property (readwrite) NSArray* pageModels;

#pragma mark - Shared

+ (ShareProxy*)sharedProxy;
+ (void)setSharedProxy:(ShareProxy*)proxy;

#pragma mark - Factories

- (ShareProxy*)newShareProxy;

- (UIActivityViewController*)newShareViewControllerWithItems:(NSArray*)items;

#pragma mark - Native Sharing

- (UIActivityViewController*)share:(id<Shareable>)shareable;
- (NSArray*)itemsFromShareable:(id<Shareable>)shareable;

#pragma mark - Helpers for alternative sharing 

- (NSURL*)shareURLForKey:(NSString*)shareKey andSite:(NSString*)site;
- (NSURL*)amplificationLinkForKey:(NSString*)shareKey;
- (NSURL*)shareURLForProduct:(ProductEntityModel*)product andSite:(NSString*)site;
- (NSString*)shareKeyForProduct:(ProductEntityModel*)product;

@end
