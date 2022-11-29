//
//  UIView+Capture.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/22/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "UIView+Capture.h"

@implementation UIView (Capture)

- (UIImage*)captureAsImage {
    CGRect bounds = self.bounds;
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:ctx];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
