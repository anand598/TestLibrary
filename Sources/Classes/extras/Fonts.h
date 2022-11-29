//
//  Fonts.h
//  Nordstrom
//
//  Created by Schell Scivally on 4/7/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Fonts : NSObject

#pragma  mark - Fonts
typedef enum {
    FontTypeMarquee,
    FontTypeCurrency,
    FontTypeNormal,
    FontTypeNormalLight,
    FontTypeSubtext,
    FontTypeItalic
} FontType;

#pragma mark - Sizes
typedef enum {
    FontSizeGiant,
    FontSizeJumbo,
    FontSizeBig,
    FontSizeLarge,
    FontSizeMedium,
    FontSizeSmall,
} FontSize;

#pragma mark - Getting a font

+ (Fonts*)fonts;
+ (void)setFonts:(Fonts*)fonts;
+ (UIFont*)fontType:(FontType)type withSize:(FontSize)size;
+ (UIFont*)fontType:(FontType)type withPointSize:(CGFloat)size;

#pragma mark - Customizing Fonts

/** The biggest, boldest font. Similar to an h1 tag. */
@property (readwrite) UIFont* marqueeFont;
/** A font used for currency display. */
@property (readwrite) UIFont* currencyFont;
/** A font used for the majority of display. */
@property (readwrite) UIFont* normalFont;
/** A font used for the majority of titles. */
@property (readwrite) UIFont* normalFontLight;
/** A font used for displaying extra information at a lower level of 
 importance. */
@property (readwrite) UIFont* subtextFont;
/** A font used for displaying extra information with some kind of "italic"
 level of attention. */
@property (readwrite) UIFont* italicFont;

@end
