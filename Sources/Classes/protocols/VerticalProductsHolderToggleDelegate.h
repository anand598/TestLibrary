//
//  VerticalProductsHolderToggleDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 6/29/17.
//
//

#import <Foundation/Foundation.h>

@class VerticalProductsHolderToggleDelegate;

@protocol VerticalProductsHolderToggleDelegate <NSObject>

-(void)toggleVerticalProductsHolderDown:(BOOL)isFromScroll;
-(void)toggleVerticalProductsBounce;
-(void)toggleVerticalProductsHolderUp;
-(void)finishedLoadingProducts;

-(void)toggleMoreProductsArrowShow;
-(void)toggleMoreProductsArrowHide;

@end
