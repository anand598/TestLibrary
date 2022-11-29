//
//  UIImage+Join.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/4/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Join)

+ (UIImage*)joinImage:(UIImage*)leftImage andImage:(UIImage*)rightImage;
- (UIImage*)joinWithRightImage:(UIImage*)rightImage;
- (UIImage*)joinWithLeftImage:(UIImage*)leftImage;
    
@end
