//
//  UIPageControl+Design.m
//  Pods
//
//  Created by Rijul Gupta on 2/25/17.
//
//

#import "UIPageControl+Design.h"

@implementation UIPageControl (Design)

- (void)updateWithDesign1{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.numberOfPages; i++) {
            UIView* dot = [self.subviews objectAtIndex:i];
            if (i == self.currentPage) {
                dot.backgroundColor = [UIColor whiteColor];
                dot.layer.cornerRadius = dot.frame.size.height / 2;
                dot.layer.borderColor = [UIColor darkGrayColor].CGColor;
                dot.layer.borderWidth = 0;
                
                dot.layer.shadowRadius  = 1.5f;
                dot.layer.shadowColor   = [UIColor colorWithRed:6.f/255.f green:4.0f/255.f blue:8.f/255.f alpha:1.f].CGColor;
                dot.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
                dot.layer.shadowOpacity = 0.9f;
                dot.layer.masksToBounds = NO;
                
            } else {
                dot.backgroundColor = [UIColor whiteColor];
                dot.layer.cornerRadius = dot.frame.size.height / 2;
                dot.layer.borderColor = [UIColor lightGrayColor].CGColor;
                dot.layer.borderWidth = 0;
                
                dot.layer.shadowColor = [UIColor clearColor].CGColor;
                
                dot.layer.shadowRadius  = 1.0f;
                dot.layer.shadowColor   = [UIColor colorWithRed:56.f/255.f green:54.0f/255.f blue:58.f/255.f alpha:1.f].CGColor;
                dot.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
                dot.layer.shadowOpacity = 1.0f;
                dot.layer.masksToBounds = NO;
                
            }
        }
        
    });
}

@end
