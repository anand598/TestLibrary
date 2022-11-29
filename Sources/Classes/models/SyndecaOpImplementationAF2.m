//
//  SyndecaOpImplementationAF2.m
//  Syndeca iOS SDK
//
//  Created by Schell on 11/27/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "SyndecaRequest.h"
#import "SyndecaOpImplementationAF2.h"
#import "NSDictionary+AsObjectOrNil.h"
//#import <AFNetworking/AFNetworking.h>
//#import <AFNetworking/AFURLRequestSerialization.h>
//#import <AFNetworking/AFURLResponseSerialization.h>

#import <ReactiveCocoa/RACEXTScope.h>

@implementation SyndecaOpImplementationAF2

- (void)loadRequest:(NSURLRequest*)request {
    [self loadRequest:request withMethod:@"GET"];
}

- (void)loadRequest:(NSURLRequest*)request withMethod:(NSString*)method {
    NSMutableURLRequest* req = [request mutableCopy];
    req.HTTPMethod = method;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    self.operation.responseSerializer = [AFJSONResponseSerializer serializer];
}


- (void)onSuccess:(void (^) (SyndecaRequest*))success onError:(void (^) (NSError* error))errBlock {
    @weakify(self);
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
        @strongify(self);
        self.parentRequest.result = responseObject;
        if (![responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            // The object is a dictionary, and might be an exception object...
            NSString* exception = [(NSDictionary*)responseObject stringByKey:@"exception"];
            if (exception) {
                // The server reported an error...
                NSString* msg = [NSString stringWithFormat:@"%s received exception from the server: %@",__func__,[responseObject description]];
                NSError* serverError = [NSError errorWithDomain:msg code:0 userInfo:@{@"request":self}];
                errBlock(serverError);
                return;
            }
        }
        
        self.parentRequest.status = SyndecaRequestStatus_Successful;
        success(self.parentRequest);
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        @strongify(self);
        NSLog(@"%s %@",__func__, error);
   
        NSMutableDictionary* userInfo = nil;
        if (error.userInfo) {
            userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
        } else {
            userInfo = [NSMutableDictionary dictionary];
        }
        [userInfo setValue:self forKey:@"request"];
        NSError* err = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
        self.parentRequest.status = SyndecaRequestStatus_Failed;
        errBlock(err);
    }];
}

- (void)start {
    [self.operation start];
}
- (void)cancel {
    [self.operation cancel];
}

@end
