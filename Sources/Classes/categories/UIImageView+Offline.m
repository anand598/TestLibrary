//
//  UIImageView+RACImage.m
//  Syndeca iOS SDK
//
//  Created by Schell on 6/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "UIImageView+Offline.h"
#import "UIImageView+ContentScale.h"
#import "UIImage+Resize.h"
#import "OfflineProxy.h"
#import "FetchProxy.h"
#import "UIImageView+AFNetworking.h"
#import <ReactiveCocoa/RACEXTScope.h>

@implementation UIImageView (Offline)

- (RACSignal*)innerloadImageWithURL:(NSURL*)url {
    AFHTTPResponseSerializer* ser = [AFImageResponseSerializer serializer];
    ser.acceptableContentTypes = [ser.acceptableContentTypes setByAddingObject:@"image/jp2"];
//    self.imageResponseSerializer = ser;
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                    placeholderImage:nil
                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                 @strongify(self);
            
            if(image){
                dispatch_async(dispatch_get_main_queue(), ^{
                                                     self.image = image;
                                                 });
                                                 [subscriber sendNext:image];
                                                 [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError errorWithDomain:@"This image has not yet been downloaded for offline." code:666 userInfo:nil]];
                }
//
                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 [subscriber sendError:error];
                             }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

- (RACSignal*)loadImageWithURL:(NSURL *)url {
    if ([FetchProxy isOffline]) {
        NSURL* path = [OfflineProxy localURLForURL:url];
        NSString* file = [path path];
        BOOL exists = [[NSFileManager defaultManager]
                       fileExistsAtPath:file];
        // Read the file off the disc or from the network.
        if (exists) {
            UIImage* img = [[UIImage alloc] initWithContentsOfFile:file];
            if (img.size.width >= 500 && img.size.height >= 500) {
                CGSize size = [UIImageView aspectFitSize:img.size insideSize:CGSizeMake(500, 500)];
//                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = [img imageWithSize:size];
//                });
            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = img;
//                });
            }
            return [[RACSignal return:img] delay:0.0001];
        }
        return [RACSignal error:[NSError errorWithDomain:@"This image has not yet been downloaded for offline." code:666 userInfo:nil]];
    }
    return [[self innerloadImageWithURL:url] map:^id(UIImage* img) {
        if (img.size.width >= 500 || img.size.height >= 500) {
            CGSize size = [UIImageView aspectFitSize:img.size insideSize:CGSizeMake(500, 500)];
            return [img imageWithSize:size];
        }
        return img;
    }];
}

- (void)cancelImageLoad {
    [self cancelImageRequestOperation];
//    [self cancelImageDownloadTask];
}

@end
