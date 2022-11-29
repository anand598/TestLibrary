//
//  UIImage+Join.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/4/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "UIImage+Join.h"

@implementation UIImage (Join)

+ (UIImage*)joinImage:(UIImage*)leftImage andImage:(UIImage*)rightImage {
    CGRect frame = CGRectZero;
    frame.size = leftImage.size;
    frame.size.width += rightImage.size.width;
    frame.size.height = MAX(frame.size.height, rightImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    UIImageView* leftView = [[UIImageView alloc] initWithImage:leftImage];
    UIImageView* rightView = [[UIImageView alloc] initWithImage:rightImage];
    CGRect right = rightView.frame;
    right.origin.x += leftImage.size.width;
    rightView.frame = right;
    
    [view addSubview:leftView];
    [view addSubview:rightView];
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)joinWithRightImage:(UIImage*)rightImage {
    return [UIImage joinImage:self andImage:rightImage];
}

- (UIImage*)joinWithLeftImage:(UIImage*)leftImage {
    return [UIImage joinImage:leftImage andImage:self];
}

@end
