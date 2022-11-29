//
//  UIViewHelper.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 2/15/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "UIViewHelper.h"

@implementation UIViewHelper

+ (UIInterfaceOrientation)orientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return orientation;
}

+ (CGRect)statusBarFrame {
    return [[UIApplication sharedApplication] statusBarFrame];
}

+ (CGRect)verticallyAutosizedRectFromFrame:(CGRect)frame withFont:(UIFont *)font andString:(NSString *)string {
    //frame.size = [string sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    frame.size = [string boundingRectWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:font.fontName} context:NULL].size;
    return frame;
}

+ (CGSize)screenSize {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat max = MAX(screenSize.width,screenSize.height);
    CGFloat min = MIN(screenSize.width,screenSize.height);
    if (UIInterfaceOrientationIsLandscape([UIViewHelper orientation])) {
        return CGSizeMake(max, min);
    }
    return CGSizeMake(min, max);
}

@end
