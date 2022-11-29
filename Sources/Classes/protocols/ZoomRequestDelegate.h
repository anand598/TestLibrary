//
//  ZoomRequestDelegate.h
//  Pods
//
//  Created by Schell Scivally on 4/11/16.
//
//

#import <Foundation/Foundation.h>

/** A ZoomRequestDelegate is an object that can handle zooming in on a specific UIView, as requested
 by some other object. The style in which the UIView is zoomed is up to the delegate. */
@protocol ZoomRequestDelegate <NSObject>

/** Asks the delegate for the view to scale when zooming is about to occur in the requesting object.
 A UIView object that will be scaled as a result of the zooming gesture. Return nil if you don’t want zooming to occur.
 */
@optional
- (UIView*)viewForZoomingIn:(id)object;
/** Tells the delegate that zooming of the content in the scroll view is about to commence. */
@optional
- (void)willBeginZooming:(id)object withView:(UIView*)view;
/** Tells the delegate that the scroll view’s zoom factor changed. */
@optional
- (void)didZoomWithScale:(CGFloat)factor;
/** Tells the delegate when zooming of the content in the scroll view completed. */
@optional
- (void)didEndZooming:(id)object withView:(UIView*)view atScale:(CGFloat)scale;

@end
