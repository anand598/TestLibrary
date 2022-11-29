//
//  TrackingResponseModel.m
//  SyndecaSDK
//
//  Created by Schell Scivally on 3/26/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "TrackingResponseModel.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation TrackingResponseModel

- (id)initWithResponseInfo:(NSDictionary*)info {
    self = [super init];
    if (self) {
        self.errored = [[info numberByKey:@"errored"] boolValue];
        self.errors = [info arrayByKey:@"errors"];
        self.events = [info arrayByKey:@"events"];
        self.message = [info stringByKey:@"message"];
        self.received = [[info numberByKey:@"received"] boolValue];
        self.saved = [[info numberByKey:@"saved"] boolValue];
        self.success = [[info numberByKey:@"success"] boolValue];
        self.timeframe = [[info numberByKey:@"timeframe"] integerValue];
        self.validated = [[info numberByKey:@"validated"] boolValue];
    }
    return self;
}

@end
