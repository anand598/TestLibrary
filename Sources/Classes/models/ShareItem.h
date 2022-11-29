//
//  ShareItem.h
//  MaryKay
//
//  Created by Schell Scivally on 9/3/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ShareItem : UIActivityItemProvider

/** Create a new ShareItem that performs the signal and returns the first value as the item. */
- (nullable id)initWithPlaceholderItem:(nonnull id)placeholderItem andSignal:(nonnull RACSignal*)signal;
/** Create a new ShareItem that with an item. */
- (nullable id)initWithItem:(nonnull id)item;
/** Create a new ShareItem with a block that takes an activity string. */
- (nullable id)initWithPlaceholderItem:(nonnull id)placeholderItem andBlock:(__nonnull id( ^ __nonnull )(NSString* __nonnull a))block;

@end
