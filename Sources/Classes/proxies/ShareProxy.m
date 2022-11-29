//
//  ShareProxy.m
//  Syndeca iOS SDK
//
//  Created by Schell on 6/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "SyndecaSDK.h"
#import "ShareProxy.h"
#import "MasterConfiguration.h"
#import "UIViewHelper.h"
#import "UIImageView+Offline.h"
#import "FetchProxy.h"
#import "FIRTrackProxy.h"
#import "NLS.h"
#import "SyndecaService.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShareProxy

- (id)init {
    self = [super init];
    if (self) {
        self.shareController = [self newShareViewControllerWithItems:@[]];
    }
    return self;
}

static ShareProxy* __shared = nil;

+ (ShareProxy*)sharedProxy {
    if (!__shared) {
        __shared = [[ShareProxy alloc] init];
    }
    return __shared;
}


+ (void)setSharedProxy:(ShareProxy*)proxy {
    __shared = proxy;
}

- (NSArray*)itemsFromShareable:(id<Shareable>)shareable {
    self.lastShareType = [shareable typeForSharing];
    return [shareable activityItems];
}

- (UIActivityViewController*)share:(id<Shareable>)shareable {
    return [self controllerToShareItems:[self itemsFromShareable:shareable]];
}

- (UIActivityViewController*)controllerToShareItems:(NSArray*)items {
    return [self newShareViewControllerWithItems:items];
}

#pragma mark - Factories

- (ShareProxy*)newShareProxy {
    return [[ShareProxy alloc] init];
}

- (void)configureShareController:(UIActivityViewController*)controller withItems:(NSArray*)items {
    NLS* nls = [NLS nlsWithName:@"email" andValidLocales:[NLS nls].validLocales];
    [nls setCurrentLocale:[NLS nls].locale];
    
    NSString* subject = [MasterConfiguration sharedConfiguration].emailShareSubject;
    subject = [nls stringFor:@"mobile.wishlist.subject"
                                            default:subject];
    // SYNIOS-185: Email share needs subject text.
    [controller setValue:subject forKeyPath:@"subject"];
    
    controller.completionHandler = ^ (NSString* activityType, BOOL completed) {
        if (completed) {
            // SYNIOS-185: Must send standard share site keys for our platform.
            [FIRTrackProxy sharedProxy].shareSite = [[MasterConfiguration
                                                  sharedConfiguration]
                                                  changeShareTypeToShareKey:activityType];
            switch (self.lastShareType) {
                case ShareTypeProduct:
                    [[FIRTrackProxy sharedProxy] trackShareProduct];
                    break;
                    
                case ShareTypePage:
                    [FIRTrackProxy sharedProxy].pageModels = self.pageModels;
                    [[FIRTrackProxy sharedProxy] trackSharePage];
                    break;
                    
                case ShareTypeSpread:
                    [[FIRTrackProxy sharedProxy] trackShareSpread];
                    break;
                    
                default:
                    break;
            }
        }
    };
}

- (UIActivityViewController*)newShareViewControllerWithItems:(NSArray*)items {
    UIActivityViewController* shareController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self configureShareController:shareController withItems:items];
    return shareController;
}

#pragma mark - Share Services

- (NSURL*)amplificationLinkForKey:(NSString*)shareKey {
    NSString* shareString = [NSString stringWithFormat:@"http://www.sharality.com/share/%@/b/",shareKey];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.sharality.com/share/%@/b/",shareKey]];
}

- (NSURL*)shareURLForKey:(NSString*)shareKey andSite:(NSString*)site {
    return [[SyndecaService sharedService] sharalityURLForSite:site andShare:shareKey];
}

- (NSURL*)shareURLForProduct:(ProductEntityModel *)product andSite:(NSString *)site {
    NSString* shareKey = [self shareKeyForProduct:product];
    return [self shareURLForKey:shareKey andSite:site];
}

- (NSString*)shareKeyForProduct:(ProductEntityModel*)product {
    // Parse the share key out of the product share url...
    NSString* sharePath = [product.url1_shareurl absoluteString];
    NSArray* split = [sharePath componentsSeparatedByString:@"/"];
    NSUInteger shareKeyIndex = [split count] - 3;
    return [split objectAtIndex:shareKeyIndex];
}

@end
