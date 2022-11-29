//
//  SyndecaOpImplementationAF2.h
//  Syndeca iOS SDK
//
//  Created by Schell on 11/27/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
//#import "AFHTTPSessionManager.h"
@class SyndecaRequest;

@interface SyndecaOpImplementationAF2 : NSObject

@property (readwrite) SyndecaRequest* parentRequest;
@property (readwrite) AFHTTPRequestOperation* operation;
//@property (readwrite) AFHTTPSessionManager* operation;

- (void)setParentRequest:(SyndecaRequest*)request;
- (SyndecaRequest*)parentRequest;
- (void)loadRequest:(NSURLRequest*)request;
- (void)loadRequest:(NSURLRequest*)request withMethod:(NSString*)method;
- (void)onSuccess:(void (^) (SyndecaRequest* request))success onError:(void (^) (NSError* error))error;
- (void)start;
- (void)cancel;

@end
