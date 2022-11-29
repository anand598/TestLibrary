//
//  VideoModel.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/24/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "VideoModel.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "PolygonModel.h"
#import "PageModel.h"

@implementation VideoModel

- (NSString*)title {
    return [self.info stringByKey:@"title"];
}

- (NSDictionary*)mp4Info {
    return [self.info valueByPath:@"data.playlist",@(0),@"medium",@(1), nil];
}
    
- (NSDictionary*)thumbInfo {
    return [self.info valueByPath:@"data.playlist",@(0),@"medium",@(0), nil];
}

- (NSURL*)URL {
    NSString* url = [[self mp4Info] stringByKey:@"url"];
    return [NSURL URLWithString:url];
}

- (NSURL*)thumbURL {
    NSString* url = [[self thumbInfo] stringByKey:@"url"];
    return [NSURL URLWithString:url];
}

- (CGFloat)width {
    return [[self mp4Info] floatByKey:@"width"];
}

- (CGFloat)height {
    return [[self mp4Info] floatByKey:@"height"];
}

- (CGRect)pageFrame {
    ElementModel* element = self.element ? self.element : [self.page elementWithWidgetID:self.ID];
    if (!element) {
        return CGRectZero;
    }
    PolygonModel* poly = element.hitAreaPolygon;
    CGRect frame = poly.bounds;
    return frame;
}

- (BOOL)isModalOnly {
    ElementModel* element = self.element ? self.element : [self.page elementWithWidgetID:self.ID];
    if (!element) {
        return NO;
    }
    
    id val = [element.info valueByPath:@"data.modal", nil];
    return [val boolValue];
}

- (NSString*)mediaId {
    NSNumber* ID = [self.info valueByPath:@"data.playlist", @(0), @"id", nil];
    return [ID stringValue];
}

- (BOOL)isAutoPlay {
    ElementModel* element = self.element ? self.element : [self.page elementWithWidgetID:self.ID];
    if (!element) {
        return false;
    }
    
    NSDictionary* data = [element.info valueForKey:@"data"];
    id k = [data valueForKey:@"autoplay"];
    BOOL autoPlay = [k boolValue];
    return autoPlay;
}

- (BOOL)isLoopEnabled {
    ElementModel* element = self.element ? self.element : [self.page elementWithWidgetID:self.ID];
    if (!element) {
        return false;
    }
    
    NSDictionary* data = [element.info valueForKey:@"data"];
    id k = [data valueForKey:@"loop"];
    BOOL autoPlay = [k boolValue];
    return autoPlay;
}


@end
