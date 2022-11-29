//
//  ColorSwatchModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 6/10/11.
//  Copyright 2011 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorSwatchModel : NSObject {
    NSString* _name;
    NSURL* _swatchURL;
    NSURL* _URL;
    NSURL* _zoomURL;
}
#pragma mark - Lifecycle
- (id)initWithJSON:(id)json;
- (id)initWithJSONString:(NSString*)jsonString;
- (id)initWithName:(NSString*)name swatchURL:(NSURL*)swatchURL URL:(NSURL*)URL andZoomURL:(NSURL*)zoomURL;

#pragma mark - Getters
- (NSString*)name;
- (NSURL*)swatchURL;
- (NSURL*)URL;
- (NSURL*)zoomURL;

@end
