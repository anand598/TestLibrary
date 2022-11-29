//
//  UINavigationController+CompletionHandler.h
//  Pods
//
//  Created by Rijul Gupta on 4/3/17.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (CompletionHandler)

- (void)completionhandler_pushViewController:(UIViewController *)viewController
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion;

@end
