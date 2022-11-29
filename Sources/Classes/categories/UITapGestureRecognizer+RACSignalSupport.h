//
//  UITapGestureRecognizer+RACSignalSupport.h
//  ReactiveCocoa
//
//  Created by Schell Scivally on 2/25/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

@interface UITapGestureRecognizer (RACSignalSupport)

+ (RACSignal*)tapThatRequires:(NSUInteger)numberOfTaps tapsOnView:(UIView *)view;
+ (RACSignal*)tapSignalOnView:(UIView*)view;
+ (RACSignal*)doubleTapSignalOnView:(UIView*)view;

@end
