//
//  NetworkErrorManager.m
//  Syndeca iOS SDK
//
//  Created by Michael Dominick on 7/15/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "NetworkErrorManager.h"

@implementation NetworkErrorManager

+ (NetworkErrorManager *)sharedManager {
    static dispatch_once_t once;
    static NetworkErrorManager* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[NetworkErrorManager alloc] init];
    });
    return sharedInstance;
}

@end
