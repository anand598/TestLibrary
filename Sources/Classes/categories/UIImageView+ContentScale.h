//
//  UIImageView+ContentScale.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/16/11.
//  Copyright (c) 2011 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ContentScale)
+ (CGSize)aspectFitSize:(CGSize)inside insideSize:(CGSize)outside;
+ (CGFloat)scaleNeededToFitSize:(CGSize)inside insideSize:(CGSize)outside;
- (CGFloat)contentScale;
- (CGSize)contentSize;
- (CGSize)contentScaleSize;
- (CGRect)contentScaleFrame;
- (UIEdgeInsets)contentInsets;
- (CGPoint)convertFromMappedPoint:(CGPoint)point;
- (CGPoint)convertToMappedPoint:(CGPoint)point;
- (CGRect)convertFromMappedFrame:(CGRect)frame;
@end
