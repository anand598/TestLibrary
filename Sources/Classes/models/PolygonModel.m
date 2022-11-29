//
//  PolygonModel.m
//  SyndecaDemo
//
//  Created by Schell Scivally on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolygonModel.h"
#import <UIKit/UIKit.h>

@implementation PolygonModel

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _points = nil;
        _highestPoint = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}


#pragma mark - Getters

- (NSArray*)points {
    if (!_points) {
        _points = [NSArray array];
    }
    return _points;
}

- (CGPoint)highestPoint {
    if (CGPointEqualToPoint(_highestPoint, CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX))) {
        CGPoint highp = CGPointMake(0, CGFLOAT_MAX);
        for (NSValue* pointVal in [self points]) {
            CGPoint p = [pointVal CGPointValue];
            if (p.y < highp.y) {
                highp = p;
            }
        }
        _highestPoint = highp;
    }
    return _highestPoint;
}

- (CGFloat)absoluteWidth {
    CGFloat max = CGFLOAT_MIN;
    CGFloat min = CGFLOAT_MAX;
    for (NSValue* pVal in [self points]) {
        CGPoint p = [pVal CGPointValue];
        if (p.x > max) {
            max = p.x;
        }
        if (p.x < min) {
            min = p.x;
        }
    }
    if (max > CGFLOAT_MIN && min < CGFLOAT_MAX) {
        return max - min;
    }
    
    return 0;
}

- (CGFloat)absoluteHeight {
    CGFloat max = CGFLOAT_MIN;
    CGFloat min = CGFLOAT_MAX;
    for (NSValue* pVal in [self points]) {
        CGPoint p = [pVal CGPointValue];
        if (p.y > max) {
            max = p.y;
        }
        if (p.y < min) {
            min = p.y;
        }
    }
    if (max > CGFLOAT_MIN && min < CGFLOAT_MAX) {
        return max - min;
    }
    
    return 0;
}

- (CGPoint)topLeft {
    CGFloat xmin = CGFLOAT_MAX;
    CGFloat ymin = CGFLOAT_MAX;
    for (NSValue* pVal in [self points]) {
        CGPoint p = [pVal CGPointValue];
        if (p.x < xmin) {
            xmin = p.x;
        }
        if (p.y < ymin) {
            ymin = p.y;
        }
    }
    if (xmin < CGFLOAT_MAX && ymin < CGFLOAT_MAX) {
        return CGPointMake(xmin, ymin);
    }
    
    return CGPointZero;
}

- (CGPoint)midPoint {
    CGPoint topLeft = [self topLeft];
    CGPoint midpoint = CGPointMake(topLeft.x + [self absoluteWidth]/2, topLeft.y + [self absoluteHeight]/2);
    return midpoint;
}

- (CGPoint)tappablePoint {
    for (NSValue* pVal in [self points]) {
        CGPoint point = [pVal CGPointValue];
        point.x += 1;
        point.y += 1;
        if ([self containsPoint:point]) {
            return point;
        }
    }
    return [[[NSSet setWithArray:[self points]] anyObject] CGPointValue];
}

- (CGRect)bounds {
    CGRect frame = CGRectZero;
    frame.origin = self.topLeft;
    frame.size.width = self.absoluteWidth;
    frame.size.height = self.absoluteHeight;
    return frame;
}

#pragma mark - Setters

- (void)setPoints:(NSArray *)points {
    _points = points;
}

#pragma mark - Hit Testing

- (BOOL)containsPoint:(CGPoint)point {
    NSInteger npol = [[self points] count];
	CGFloat x = point.x;
	CGFloat y = point.y;
    // We're going to turn our array into raw arrays of CGFloats...
	CGFloat xp[npol];
	CGFloat yp[npol];
	for (NSInteger i = 0; i < npol; i++) {
		CGPoint vertex = [(NSValue*)[[self points] objectAtIndex:i] CGPointValue];
		xp[i] = vertex.x;
		yp[i] = vertex.y;
	}
	// Then we'll check how many segments a ray reaching out from
    // the point crosses...
	NSInteger i, j, c = 0;
	for (i = 0, j = npol-1; i < npol; j = i++) {
        if ((((yp[i] <= y) && (y < yp[j])) ||
             ((yp[j] <= y) && (y < yp[i]))) &&
            (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
			c = !c;
	}
    // If our ray crossed an odd number of segments, it's inside the polygon,
    // if not, it's outside (works event for polygons with holes)...
	return c == 1; 
}

@end
