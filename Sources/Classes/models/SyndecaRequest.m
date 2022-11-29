//
//  SyndecaRequest.m
//  CocoaViewer
//
//  Created by Schell Scivally on 11/16/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "SyndecaRequest.h"
#import "ExternalLinkParams.h"
#import "UIDevice+Stats.h"
#import "SyndecaOpImplementationAF2.h"


@implementation SyndecaRequest

- (id)init {
    self = [super init];
    if (self) {
        self.status = SyndecaRequestStatus_None;
        self.operation = nil;
        self.resource = nil;
        self.result = nil;
        self.type = SyndecaRequestType_Unknown;
        self.postData = nil;
    }
    return self;
}

#pragma mark - Exceptions

- (void)checkExceptions {
    if (![self resource]) {
        [NSException raise:@"request has no resource" format:@""];
    }
}

#pragma mark - Control

// This is an older way to start requests and I don't *think* it's still used.
- (void)start {
    [self checkExceptions];
    
    [self startWithCompleteBlock:^(SyndecaRequest* request) {
        [self.delegate requestDidFinish:request];
    } andError:^(NSError* error) {
        [self.delegate requestDidFail:self];
    }];
    [self.delegate requestDidStart:self];
}

- (void)startWithCompleteBlock:(SyndecaRequestCompleteBlock)complete andError:(SyndecaRequestFailBlock)errBlock {
    [self checkExceptions];
    NSLog(@"%s sending request for resource:\n    %@",__func__,[self resource]);
    
    self.status = SyndecaRequestStatus_Started;
    
    NSURLRequest* URLRequest = nil;
    if (self.postData) {
        NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.resource]];
        postRequest.HTTPMethod = @"POST";
        postRequest.HTTPBody = self.postData;
        URLRequest = postRequest;
    } else {
        URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.resource]];
    }
    
    NSString* reqMethod = @"GET";
    if (self.method == SyndecaRequestMethod_Head) {
        reqMethod = @"HEAD";
    }
    if (self.type == SyndecaRequestType_Tracking) {
        reqMethod = @"POST";
    }

    self.operation = [[SyndecaOpImplementationAF2 alloc] init];
    [self.operation setParentRequest:self];
    [self.operation loadRequest:URLRequest withMethod:reqMethod];
    [self.operation onSuccess:complete onError:errBlock];
    [self.operation start];
}

- (void)cancel {
    [self.operation cancel];
}

- (void)enableArchiveFlag {
    NSURL* URL = [NSURL URLWithString:self.resource];
    self.resource = [[ExternalLinkParams
                     appendParams:@{@"archive" : @"1"} toURL:URL]
                     absoluteString];
    
}

#pragma mark - Helpers

- (NSString*)description {
    NSString* desc = [super description];
    NSString* type = @"unknown";
    switch ([self type]) {
        case SyndecaRequestType_Guide:
            type = @"SyndecaRequestType_Guide";
        break;
        case SyndecaRequestType_Catalog:
            type = @"SyndecaRequestType_Catalog";
        break;
        case SyndecaRequestType_Product:
            type = @"SyndecaRequestType_Product";
        break;
        default:
            type = @"SyndecaRequestType_Unknown";
        break;
    }
    desc = [desc stringByAppendingFormat:@"\n    type:%@\n    resource:%@",type,[self resource]];
    return desc;
}

- (void)initializeHEAD {
}

@end
