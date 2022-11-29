//
//  IssueModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "IssueModel.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "UIDevice+Resolution.h"

@implementation IssueModel

SYNTHESIZE_DI

- (id)initWithInfo:(NSDictionary *)info {
    self = [super initWithInfo:info];
    if (self) {
        self.accessOutOfGuide = NO;
    }
    return self;
}

- (NSUInteger)numberId {
    NSDictionary* data = [self.info infoByKey:@"data"];
    NSUInteger ID = [data uintByKey:@"catalogID"];
    return ID;
}

- (NSString*)ID {
    NSUInteger ID = self.numberId;
    return [NSString stringWithFormat:@"%lu",(unsigned long)ID];
}

- (NSURL*)coverURL {
    return [self imageURLForResolution:[[UIDevice currentDevice] resolution]];
}

- (NSInteger)roughFileSizeInBytes {
    // MKYQA-236
    // Downloading a catalog is unacceptably slow or not working
    //
    // Added better filesize estimates using values provided by the platform.
    NSDictionary* info = [self info];
    NSDictionary* data = [info infoByKey:@"data"];
    NSInteger size = 0;
    if (data) {
        NSDictionary* sizes = [data infoByKey:@"filesizes"];
        if (sizes && [sizes isKindOfClass:[NSDictionary class]]) {
            for (NSNumber* num in [sizes allValues]) {
                NSInteger numsize = [num integerValue];
                size = size + numsize;
            }
        }
    }
    return size;
}

- (NSURL*)thumbURLForResolution:(NSString *)resolution {
    NSURL* url = [[self thumbURLs] valueForKey:resolution];
    if (url) {
        return url;
    }
    // Do some error logging...
    return nil;
}

- (NSURL*)imageURLForResolution:(NSString *)resolution {
    NSURL* url = [[self imageURLs] valueForKey:resolution];
    if (url) {
        return url;
    }
    
    // Do some error logging...
    NSLog(@"Warning! Cannot find image URL for resolution %@ - options are:%@",resolution,[self imageURLs]);
    if ([[[self imageURLs] allValues] count]) {
        return [[[self imageURLs] allValues] firstObject];
    }
    return nil;
}

- (NSString*)key {
    return [self.info[@"data"] stringByKey:@"catalogKey"];
}

/** The title of the issue. */
- (NSString*)title {
    return [self.info stringByKey:@"title"];
}
/** Whether or not this is a featured issue. */
- (BOOL)isFeatured {
    return [self.info[@"data"][@"featured"] boolValue];
}
/** The build number of this issue. API1 only. */
- (NSString*)buildNum {
    NSUInteger buildNum = [self.info[@"data"] uintByKey:@"buildNum"];
    return [NSString stringWithFormat:@"%lu",(unsigned long)buildNum];
};
/** A list of URLs of thumb cover images, keyed by resolution. */
- (NSDictionary*)thumbURLs{
    NSMutableDictionary* thumbURLs = [NSMutableDictionary dictionary];
    for (NSDictionary* display in self.info[@"data"][@"displays"]) {
        NSString* thumbPath = [display stringByKey:@"cover_thumb_url"];
        NSArray* sizes = (NSArray*)[display arrayByKey:@"sizes"];
        if (sizes) {
            for (NSString* size in sizes) {
                [thumbURLs setValue:[NSURL URLWithString:thumbPath] forKey:size];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:thumbURLs];
}
/** A list of URLs of full size cover images, keyed by resolution. */
- (NSDictionary*)imageURLs{
    NSMutableDictionary* imageURLs = [NSMutableDictionary dictionary];
    for (NSDictionary* display in self.info[@"data"][@"displays"]) {
        NSString* imagePath = [display stringByKey:@"cover_image_url"];
        NSArray* sizes = (NSArray*)[display arrayByKey:@"sizes"];
        if (sizes) {
            for (NSString* size in sizes) {
                [imageURLs setValue:[NSURL URLWithString:imagePath] forKey:size];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:imageURLs];
}
/** An integer specifying the issue's sort order. */
- (NSUInteger)sortOrder {
    NSUInteger sort = [self.info hasKey:@"sortOrder"] ? [self.info uintByKey:@"sortOrder"] : NSUIntegerMax;
    return sort;
}

@end
