//
//  UIImage+SyndecaSDK.m
//  Pods
//
//  Created by Schell Scivally on 1/19/16.
//
//

#import "UIImage+SyndecaSDK.h"
#import "SyndecaConfig.h"
@implementation UIImage (SyndecaSDK)

+ (UIImage *)SDKImageNamed:(NSString *)imageName {
    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[SyndecaConfig class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
    NSString* imageFileName = [NSString stringWithFormat:@"%@.png",imageName];
    UIImage* image = [UIImage imageNamed:imageFileName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (NSURL *)SDKURLNamed:(NSString *)imageName {
    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[SyndecaConfig class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
    NSString* imageFileName = [NSString stringWithFormat:@"%@.png",imageName];
    NSURL *url = [bundle URLForResource:imageName withExtension:@"gif"];
    return url;
}

@end
