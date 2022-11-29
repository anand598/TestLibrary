//
//  UIImage+SyndecaSDK.h
//  Pods
//
//  Created by Schell Scivally on 1/19/16.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (SyndecaSDK)

+ (UIImage*)SDKImageNamed:(NSString*)name;
+ (NSURL *)SDKURLNamed:(NSString *)imageName;
@end
