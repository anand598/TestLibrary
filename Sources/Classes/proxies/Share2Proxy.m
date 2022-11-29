//
//  Share2Proxy.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/21/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "Share2Proxy.h"

@implementation Share2Proxy

- (NSURL*)amplificationLinkForKey:(NSString*)shareKey {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://mk.sharality.com/share/%@/b/",shareKey]];
}

- (NSURL*)shareURLForKey:(NSString*)shareKey andSite:(NSString*)site {
    NSString* fmt = @"http://mk.api.syndeca.com/v1/rest/share/%@/302/%@";
    NSString* str = [NSString stringWithFormat:fmt, shareKey, site];
    return [NSURL URLWithString:str];
}

- (ShareProxy*)newShareProxy {
    return [[Share2Proxy alloc] init];
}

@end
