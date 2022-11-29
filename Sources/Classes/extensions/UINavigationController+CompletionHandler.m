//
//  UINavigationController+CompletionHandler.m
//  UINavigationController+CompletionHandler
//  Pods
//
//  Created by Rijul Gupta on 4/3/17.
//
//
#import "UINavigationController+CompletionHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (CompletionHandler)

- (void)completionhandler_pushViewController:(UIViewController *)viewController
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self pushViewController:viewController animated:animated];
    [CATransaction commit];
}

@end
