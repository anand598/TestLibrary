//
//  SpreadModel.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/4/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "LeftAndRightShareable.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIImageView+Offline.h"
#import "UIImage+Join.h"
#import "NLS.h"
#import "ShareItem.h"

@implementation LeftAndRightShareable

- (RACSignal*)imageForSharing {
    id<Shareable> l = self.left;
    id<Shareable> r = self.right;
    RACSignal* s = [RACSignal combineLatest:@[[l imageForSharing], [r imageForSharing]]];
    return [s map:^UIImage*(RACTuple* value) {
        RACTupleUnpack(UIImage* left, UIImage* right) = value;
        return [left joinWithRightImage:right];
    }];
}

- (NSString*)textForSharingForActivity:(NSString*)a {
    id<Shareable> l = self.left;
    id<Shareable> r = self.right;
    
    if ([l isKindOfClass:[PageModel class]]) {
        PageModel* lp = (PageModel*)l;
        PageModel* rp = (PageModel*)r;
        NSString* shareTitle = [[NLS nls] stringFor:@"share.socialTitle" default:@""];
        NSString* catalogName = lp.catalog.title;
        NSString* catalogDesc = @"";
        NSString* pageName = [NSString stringWithFormat:@"%@ - %@",lp.title,rp.title];
        if ([a isEqualToString:UIActivityTypePostToTwitter]) {
            return [NSString stringWithFormat:@"%@ %@\n%@",catalogName,pageName,catalogDesc];
        }
        return [NSString stringWithFormat:@"%@\n%@ %@\n%@",shareTitle,catalogName,pageName,catalogDesc];
    }
    
    return [NSString stringWithFormat:@"%@ - %@",[l textForSharingForActivity:a], [r textForSharingForActivity:a]];
}

- (NSURL*)URLForSharing {
    if ([self.left URLForSharing]) {
        return [self.left URLForSharing];
    };
    return [self.right URLForSharing];
}

- (NSArray*)activityItems {
    return @[[[ShareItem alloc] initWithPlaceholderItem:@"image" andSignal:[self imageForSharing]],
             [[ShareItem alloc] initWithPlaceholderItem:@"text" andBlock:^id(NSString *a) {
                 return [self textForSharingForActivity:a];
             }],
             [[ShareItem alloc] initWithItem:[self URLForSharing]]];
}

- (ShareType)typeForSharing {
    return ShareTypeSpread;
}

@end
