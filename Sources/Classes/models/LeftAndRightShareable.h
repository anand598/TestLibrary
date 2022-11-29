//
//  SpreadModel.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/4/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/Shareable.h>
#import <SyndecaSDK/PageModel.h>

@interface LeftAndRightShareable : NSObject <Shareable>

@property (readwrite) id<Shareable> left;
@property (readwrite) id<Shareable> right;

@end
