//
//  DudTrackProxy.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/14/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "DudTrackProxy.h"

@implementation DudTrackProxy

- (id)initWithInterval:(NSTimeInterval)interval {
    self = [super initWithInterval:interval];
    if (self) {
        self.sendEventsSignal = nil;
        self.cache = nil;
        self.lastResponse = nil;
    }
    return self;
}
- (void)addEvent:(TrackingEventModel *)eventModel { }
- (void)sendEvents {}

@end
