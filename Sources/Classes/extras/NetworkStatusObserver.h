//
//  NetworkStatusObserver.h
//  MaryKay
//
//  Created by Michael Dominick on 9/18/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkStatusObserver : NSObject

+ (NetworkStatusObserver *)sharedObserver;

- (void)start;

@property (nonatomic) BOOL hasNetworkConnection;

@end
