//
//  PolygonModel.h
//  SyndecaDemo
//
//  Created by Schell Scivally on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

/** An object containing a set of points and a number of convenience 
 methods for common operations with lists of points. */
@interface PolygonModel : NSObject {
    NSArray* _points;
    CGPoint _highestPoint;
}

#pragma mark - Getters
/** The vertices of the polygon. */
- (NSArray*)points;
/** Returns the highest point in the polygon. */
- (CGPoint)highestPoint;
/** Returns the absolute width (the width from the rightmost to leftmost point). */
- (CGFloat)absoluteWidth;
/** Returns the absolute height (the height from the rightmost to leftmost point). */
- (CGFloat)absoluteHeight;
/** The topmost-leftmost point. */
- (CGPoint)topLeft;
/** The midpoint of this polygon. */
- (CGPoint)midPoint;
/** A point that lies inside the hitarea. Use this for testing. */
- (CGPoint)tappablePoint;
/** The polygon's bounding box. */
- (CGRect)bounds;
    
#pragma mark - Setters
/** Sets the vertices of the polygon. */
- (void)setPoints:(NSArray*)points;

#pragma mark - Hit Testing
/** Returns whether or not the point is within the polygon.
 
 @param point The point to test.
 */
- (BOOL)containsPoint:(CGPoint)point;

@end
