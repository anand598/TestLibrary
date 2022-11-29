//
//  PrefetchImageCacheDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 5/22/17.
//
//

#import <Foundation/Foundation.h>

@class PrefetchImageCacheDelegate;

@protocol PrefetchImageCacheDelegate <NSObject>

/** Called by a view object requesting an image view from a controller. Stores the images in a cache that can be pre-loaded to greatly improve speed in uicollectionviews and uitableviews */
- (void)getImageFromUrl:(NSURL *)url
      completionHandler:(void (^)(UIImage *image, NSError * err))completionBlock;


@end
