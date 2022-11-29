//
//  UIImageView+ContentScale.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/16/11.
//  Copyright (c) 2011 Synapse Group International, Inc. All rights reserved.
//

#import "UIImageView+ContentScale.h"

@implementation UIImageView (ContentScale)

+ (CGSize)aspectFitSize:(CGSize)inside insideSize:(CGSize)outside {
    CGFloat scale = [UIImageView scaleNeededToFitSize:inside insideSize:outside];

    CGFloat newWidth = scale * inside.width;
    CGFloat newHeight = scale * inside.height;
    
    CGSize size = CGSizeMake(newWidth, newHeight);
    return size;
}

+ (CGFloat)scaleNeededToFitSize:(CGSize)inside insideSize:(CGSize)outside {
    CGFloat widthScale = outside.width / inside.width;
    CGFloat heightScale = outside.height / inside.height;
    CGFloat scale = MIN(widthScale, heightScale);
    return scale;
}

- (CGFloat)contentScale {
    if (CGSizeEqualToSize(self.image.size, CGSizeZero)) {
        return 1.0;
    }
    
    CGRect bounds = self.bounds;
    CGFloat widthScale = bounds.size.width / self.image.size.width;
    CGFloat heightScale = bounds.size.height / self.image.size.height;
    
    if (self.contentMode == UIViewContentModeScaleToFill) {
        return (widthScale==heightScale) ? widthScale : NAN;
    }
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        return MIN(widthScale, heightScale);
    }
    if (self.contentMode == UIViewContentModeScaleAspectFill) {
        return MAX(widthScale, heightScale);
    }
    return 1.0;
}

- (CGSize)contentSize {
    return [[self image] size];
}

- (CGSize)contentScaleSize {
    CGSize imgSize = [self contentSize];
    CGFloat scale = [self contentScale];
    return CGSizeMake(imgSize.width*scale, imgSize.height*scale);
}

- (CGRect)contentScaleFrame {
    CGSize size = [self contentScaleSize];
    UIEdgeInsets insets = [self contentInsets];
    return CGRectMake(insets.left, insets.top, size.width, size.height);
}

- (UIEdgeInsets)contentInsets {
    CGSize scaleSize = [self contentScaleSize];
    CGSize size = self.bounds.size;
    CGFloat hInset = (size.width - scaleSize.width)/2;
    CGFloat vInset = (size.height - scaleSize.height)/2;
    return UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
}

- (CGPoint)convertFromMappedPoint:(CGPoint)point {
    UIEdgeInsets insets = [self contentInsets];
    CGSize size = [self contentScaleSize];
    CGPoint converted = CGPointMake(size.width/100*point.x, size.height/100*point.y);
    converted.x += insets.left;
    converted.y += insets.top;
    return converted;
}

- (CGPoint)convertToMappedPoint:(CGPoint)point {
    UIEdgeInsets insets = [self contentInsets];
    CGSize size = [self contentScaleSize];
    point.x -= insets.left;
    point.y -= insets.top;
    return CGPointMake(100*point.x/size.width, 100*point.y/size.height);
}

- (CGRect)convertFromMappedFrame:(CGRect)frame {
    CGPoint topLeft = [self convertFromMappedPoint:frame.origin];
    CGPoint bottomRight = [self convertFromMappedPoint:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height)];
    CGRect frame_ = CGRectZero;
    frame_.origin = topLeft;
    frame_.size.width = bottomRight.x - topLeft.x;
    frame_.size.height = bottomRight.y - topLeft.y;
    return frame_;
}

@end
