//
//  TrackingResponseModel.h
//  SyndecaSDK
//
//  Created by Schell Scivally on 3/26/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackingResponseModel : NSObject

- (id)initWithResponseInfo:(NSDictionary*)info;

@property (readwrite) BOOL errored;
@property (readwrite) NSArray* errors;
@property (readwrite) NSArray* events;
@property (readwrite) NSString* message;
@property (readwrite) BOOL received;
@property (readwrite) BOOL saved;
@property (readwrite) BOOL success;
@property (readwrite) NSUInteger timeframe;
@property (readwrite) BOOL validated;

@end
