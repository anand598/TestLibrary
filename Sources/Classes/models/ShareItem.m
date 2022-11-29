//
//  ShareItem.m
//  MaryKay
//
//  Created by Schell Scivally on 9/3/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "ShareItem.h"

@interface ShareItem ()
@property (readwrite) RACSignal* signal;
@property (readwrite) id theItem;
@property (readwrite, copy) id (^block)(NSString*);
@end

@implementation ShareItem

- (id)initWithPlaceholderItem:(nonnull id)placeholderItem andSignal:(nonnull RACSignal*)signal {
    self = [super initWithPlaceholderItem:placeholderItem];
    if (self) {
        self.signal = signal;
        self.theItem = nil;
    }
    return self;
}

- (id)initWithItem:(nonnull id)item {
    self = [super initWithPlaceholderItem:item];
    if (self) {
        self.theItem = item;
    }
    return self;
}

- (nullable id)initWithPlaceholderItem:(nonnull id)placeholderItem andBlock:(id(^)(NSString*))block {
    self = [super initWithPlaceholderItem:placeholderItem];
    if (self) {
        self.signal = nil;
        self.block = block;
    }
    return self;
}

- (nonnull id)item {
    if (self.theItem) {
        return self.theItem;
    }
    
    if (self.block) {
        id item = self.block(self.activityType);
        if ([item respondsToSelector:@selector(deliverOn:)]) {
            // This item is a signal for an image or something defferred.
            self.signal = item;
        } else {
            return item;
        }
    }
    
    if (self.signal) {
        
        RACSignal* go = [self.signal deliverOn:[RACScheduler immediateScheduler]];
        __block id item = nil;
        __block BOOL done = NO;
        [go subscribeNext:^(id x) {
            item = x;
        } error:^(NSError *error) {
            done = YES;
        } completed:^{
            done = YES;
        }];
        
        // For some reason the immediateScheduler still isn't firing synchronously, so we force it...
        NSDate* before = [NSDate dateWithTimeIntervalSinceNow:0];
        while (!done) {
            NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
            if ([now timeIntervalSinceDate:before] > 6) {
                // MKYQA-517
                // If it takes more than 6 seconds to complete this task just return nil,
                // we don't want this thread to hang.
                return nil;
            }
        }
        
        return item;
    }
    return nil;
}

@end
