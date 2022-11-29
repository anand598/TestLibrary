//
//  SyndecaOperationImplementor.h
//  Syndeca iOS SDK
//
//  Created by Schell on 11/27/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SyndecaRequest;

@protocol SyndecaOperationImplementor <NSObject>

- (void)setParentRequest:(SyndecaRequest*)request;
- (SyndecaRequest*)parentRequest;
- (void)loadRequest:(NSURLRequest*)request;
- (void)onSuccess:(void (^) (SyndecaRequest* request))success onError:(void (^) (NSError* error))error;
- (void)start;
- (void)cancel;

@end
