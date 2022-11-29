//
//  UIImageView+RACImage.h
//  Syndeca iOS SDK
//
//  Created by Schell on 6/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UIImageView (Offline)

- (RACSignal*)loadImageWithURL:(NSURL*)url;
- (void)cancelImageLoad;

@end
