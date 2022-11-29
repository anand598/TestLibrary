//
//  UIViewHelper.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 2/15/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_LANDSCAPE (UIInterfaceOrientationIsLandscape([UIViewHelper orientation]))
#define IS_PORTRAIT (UIInterfaceOrientationIsPortrait([UIViewHelper orientation]))
#define IS_IPHONE_X (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && UIScreen.mainScreen.nativeBounds.size.height == 2436)

/** View blocks */
typedef CGRect (^UIViewFrameBlock) (UIView* view);
typedef CGPoint (^UIViewOffsetBlock) (UIView* view);
typedef CGSize (^UIViewSizeBlock) (UIView* view);
/** ScrollView blocks */
typedef CGPoint (^UIScrollViewContentOffsetBlock) (UIScrollView* scrollView);
typedef CGSize (^UIScrollViewContentSizeBlock) (UIScrollView* scrollView);

/** Used to frame views. 
 Contains utility functions that are general enough to be used everywhere. */
@interface UIViewHelper : NSObject

+ (UIInterfaceOrientation)orientation;
+ (CGRect)statusBarFrame;
+ (CGRect)verticallyAutosizedRectFromFrame:(CGRect)frame
                                  withFont:(UIFont *)font
                                 andString:(NSString *)string;
+ (CGSize)screenSize;

@end
