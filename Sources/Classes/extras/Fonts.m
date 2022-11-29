//
//  Fonts.m
//  Nordstrom
//
//  Created by Schell Scivally on 4/7/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "Fonts.h"

@interface Fonts ()

@property (readwrite) NSDictionary* stepMap;

@end

@implementation Fonts

- (id)init {
    self = [super init];
    if (self) {
        self.marqueeFont = [UIFont systemFontOfSize:14];
        self.normalFont = [UIFont systemFontOfSize:12];
        self.normalFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        self.normalFontLight = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        self.currencyFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        self.subtextFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        self.italicFont = [UIFont systemFontOfSize:8];
        UIFontDescriptor* fd = [self.italicFont fontDescriptor];
        UIFontDescriptor* fd2 = [fd fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        self.italicFont = [UIFont fontWithDescriptor:fd2 size:8];
        
        self.stepMap = @{@(FontSizeSmall) : @(8),
                         @(FontSizeMedium) : @(12),
                         @(FontSizeLarge) : @(16),
                         @(FontSizeBig) : @(20),
                         @(FontSizeJumbo) : @(24),
                         @(FontSizeGiant) : @(32)};

    }
    return self;
}

static Fonts* __sharedFonts = nil;;
+ (Fonts*)fonts {
    if (!__sharedFonts) {
        __sharedFonts = [[Fonts alloc] init];
    }
    return __sharedFonts;
}

+ (void)setFonts:(Fonts*)fonts {
    __sharedFonts = fonts;
}

- (NSDictionary*)fontMap {
    return @{@(FontTypeMarquee) : self.marqueeFont,
             @(FontTypeNormal) : self.normalFont,
             @(FontTypeNormalLight) : self.normalFontLight,
             @(FontTypeCurrency) : self.currencyFont,
             @(FontTypeItalic) : self.italicFont,
             @(FontTypeSubtext) : self.subtextFont};
}


+ (UIFont*)fontType:(FontType)type withSize:(FontSize)size {
    NSDictionary* fontMap = [[Fonts fonts] fontMap];
    NSDictionary* stepMap = [Fonts fonts].stepMap;
    
    UIFont* font = [fontMap objectForKey:@(type)];
    CGFloat inc = [[stepMap objectForKey:@(size)] floatValue];
    return [font fontWithSize:inc];
}

+ (UIFont*)fontType:(FontType)type withPointSize:(CGFloat)size{
    NSDictionary* fontMap = [[Fonts fonts] fontMap];
    UIFont* font = [fontMap objectForKey:@(type)];
    return [font fontWithSize:size];
}

@end
