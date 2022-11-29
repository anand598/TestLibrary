//
//  UIImage+Resize.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 3/24/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage*)imageWithSize:(CGSize)newSize {
//    UIGraphicsBeginImageContext( newSize );
//    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return newImage;
    
    // Scalling selected image to targeted size
       CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
       CGContextRef context = CGBitmapContextCreate(NULL, newSize.width, newSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
       CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));

       if(self.imageOrientation == UIImageOrientationRight)
       {
           CGContextRotateCTM(context, -M_PI_2);
           CGContextTranslateCTM(context, -newSize.height, 0.0f);
           CGContextDrawImage(context, CGRectMake(0, 0, newSize.height, newSize.width), self.CGImage);
       }
       else
           CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), self.CGImage);

       CGImageRef scaledImage=CGBitmapContextCreateImage(context);

       CGColorSpaceRelease(colorSpace);
       CGContextRelease(context);

       UIImage *image = [UIImage imageWithCGImage: scaledImage];

       CGImageRelease(scaledImage);

       return image;
}

@end
