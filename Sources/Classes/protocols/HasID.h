//
//  HasID.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/17/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HasID <NSObject>

- (NSString*)ID;
- (NSDictionary*)info;

@end
