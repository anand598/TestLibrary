//
//  ColorSwatchModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 6/10/11.
//  Copyright 2011 Synapse Group International, Inc. All rights reserved.
//

#import "ColorSwatchModel.h"

@implementation ColorSwatchModel

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _name = nil;
        _URL = nil;
        _swatchURL = nil;
        _zoomURL = nil;
    }
    return self;
}

- (id)initWithJSON:(id)json {
    self = [self init];
    if (self) {
        NSString* nameString = [json valueForKey:@"Name"];
        if (nameString && ![nameString isEqual:[NSNull null]]) {
            _name = nameString;
        }
        NSObject* swatch = [json valueForKey:@"ColorSwatchUrl"];
        if ([[swatch class] isSubclassOfClass:[NSString class]]) {
            NSString* swatchString = (NSString*)swatch;
            if (![swatchString isEqual:[NSNull null]]) {
                _swatchURL = [[NSURL alloc] initWithString:swatchString];
            }
        }
        NSString* zoom = [json valueForKey:@"ZoomImageUrl"];
        if (zoom && ![zoom isEqual:[NSNull null]]) {
            _zoomURL = [[NSURL alloc] initWithString:zoom];
        }
    }
    return self;
}

- (id)initWithJSONString:(NSString*)jsonString {
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self = [self initWithJSON:json];
    return self;
}

- (id)initWithName:(NSString*)name swatchURL:(NSURL*)swatchURL URL:(NSURL*)URL andZoomURL:(NSURL*)zoomURL {
    self = [self init];
    if (self) {
        _name = name;
        _swatchURL = swatchURL;
        _URL = URL;
        _zoomURL = zoomURL;
    }
    return self;
}


#pragma mark - Getters

- (NSString*)name {
    return _name;
}

- (NSURL*)swatchURL {
    return _swatchURL;
}

- (NSURL*)URL {
    return _URL;
}

- (NSURL*)zoomURL {
    return _zoomURL;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<ColorSwatchModel name:%@ URL:%@ swatchURL:%@ zoomURL:%@>",[self name],[[self URL] absoluteString],[[self swatchURL] absoluteString],[[self zoomURL] absoluteString]];
}

- (NSUInteger)hash {
    return [[self description] hash];
}

- (BOOL)isEqual:(id)object {
    ColorSwatchModel* color = (ColorSwatchModel*)object;
    if (!color) {
        return NO;
    }
    return [object hash] == [self hash];
}


@end
