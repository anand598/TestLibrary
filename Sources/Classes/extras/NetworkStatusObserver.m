//
//  NetworkStatusObserver.m
//  MaryKay
//
//  Created by Michael Dominick on 9/18/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "NetworkStatusObserver.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
@implementation NetworkStatusObserver

+ (NetworkStatusObserver *)sharedObserver {
    static dispatch_once_t once;
    static NetworkStatusObserver* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[NetworkStatusObserver alloc] init];
        [sharedInstance config];
    });
    return sharedInstance;
}

- (void)config {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1: {
                // AFNetworkReachabilityStatusUnknown = -1,
                self.hasNetworkConnection = NO;
                NSLog(@"The reachability status is Unknown");
                break;
            }
            case 0: {
                NSLog(@"The reachability status is not reachable");
                self.hasNetworkConnection = NO;
                break;
            }
            default: {
                self.hasNetworkConnection = YES;
                break;
            }
                
        }
    }];
}

- (void)start {
    // non-op since config is handled in sharedObserver.
}

@end
