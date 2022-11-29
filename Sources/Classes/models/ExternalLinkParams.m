//
//  ExternalLinkParams.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/2/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ExternalLinkParams.h"
#import "NSString+Helpers.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation ExternalLinkParams

static ExternalLinkParams* __shared = nil;
+ (ExternalLinkParams*)sharedParams {
    if (!__shared) {
        __shared = [[ExternalLinkParams alloc] init];
    }
    return __shared;
}

+ (void)setSharedParams:(ExternalLinkParams*)shared {
    __shared = shared;
}

+ (NSString*)queryStringFromInfo:(NSDictionary*)info {
    NSArray* keyvals = @[];
    for (NSString* key in [info allKeys]) {
        NSString* value = [info stringByKey:key];
        value = [value urlEncodedString];
        keyvals = [keyvals arrayByAddingObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }
    return [keyvals componentsJoinedByString:@"&"];
}

+ (NSDictionary*)queryInfoWithURL:(NSURL*)url {
    NSArray* thatQuery = [url.query componentsSeparatedByString:@"&"];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    for (NSString* keyval in thatQuery) {
        NSArray* sep = [keyval componentsSeparatedByString:@"="];
        if ([sep count] > 1) {
            [info setObject:sep[1] forKey:sep[0]];
        } else {
            [info setObject:[NSNull null] forKey:sep[0]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:info];
}

+ (NSDictionary*)merge:(NSDictionary*)override with:(NSDictionary*)base {
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    for (NSString* key in base) {
        [info setObject:[base objectForKey:key] forKey:key];
    }
    for (NSString* key in override) {
        [info setObject:[override objectForKey:key] forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:info];
}

+ (NSURL*)appendParams:(NSDictionary*)params toURL:(NSURL*)URL {
    if (!URL) {
        return nil;
    }
    NSString* abs = [URL absoluteString];
    NSDictionary* thatQuery = [ExternalLinkParams queryInfoWithURL:URL];
    NSDictionary* allParams = [ExternalLinkParams merge:thatQuery with:params];
    NSString* query = [URL query];
    NSString* newquery = [ExternalLinkParams queryStringFromInfo:allParams];
    NSString* urlStr;
    if (query) {
        urlStr = [abs stringByReplacingOccurrencesOfString:[URL query] withString:newquery];
    } else if (![newquery isEqualToString:@""]) {
        urlStr = [abs stringByAppendingFormat:@"?%@",newquery];
    } else {
        urlStr = abs;
    }
    
    return [NSURL URLWithString:urlStr];
}

+ (NSURL*)replaceParams:(NSDictionary*)params inURL:(NSURL*)URL {
    if (!URL) {
        return nil;
    }
    NSString* abs = [URL absoluteString];
    NSDictionary* thatQuery = [ExternalLinkParams queryInfoWithURL:URL];
    NSDictionary* allParams = [ExternalLinkParams merge:params with:thatQuery];
    NSString* query = [URL query];
    NSString* newquery = [ExternalLinkParams queryStringFromInfo:allParams];
    NSString* urlStr;
    if (query) {
        urlStr = [abs stringByReplacingOccurrencesOfString:[URL query] withString:newquery];
    } else {
        urlStr = [abs stringByAppendingFormat:@"?%@",newquery];
    }
    
    return [NSURL URLWithString:urlStr];
}

- (id)init {
    self = [super init];
    if (self) {
        self.params = @{};
    }
    return self;
}

- (NSURL*)appendParamsToURL:(NSURL *)URL {
    return [ExternalLinkParams appendParams:self.params toURL:URL];
}

@end
