//
//  UITapGestureRecognizer+RACSignalSupport.m
//  ReactiveCocoa
//
//  Created by Schell Scivally on 2/25/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UITapGestureRecognizer+RACSignalSupport.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation UITapGestureRecognizer (RACSignalSupport)

+ (RACSignal*)tapThatRequires:(NSUInteger)numberOfTaps tapsOnView:(UIView *)view {
	@weakify(view);
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		@strongify(view);
		// Create a tap that posts to the subscriber.
		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:subscriber action:@selector(sendNext:)];
        tap.numberOfTapsRequired = numberOfTaps;
		// Add it to the view.
		[view addGestureRecognizer:tap];
		// Clean up.
		return [RACDisposable disposableWithBlock:^{
			// Remove the tap.
			[view removeGestureRecognizer:tap];
		}];
	}];
}

+ (RACSignal*)tapSignalOnView:(UIView *)view {
    return [self tapThatRequires:1 tapsOnView:view];
}

+ (RACSignal*)doubleTapSignalOnView:(UIView *)view {
    return [self tapThatRequires:2 tapsOnView:view];
}

@end
